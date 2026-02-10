import Foundation

public final class SimulatorManager: Sendable {

    private let xcrunPath: String

    public init() {
        self.xcrunPath = Shell.which("xcrun") ?? "/usr/bin/xcrun"
    }

    // MARK: - Querying

    public func listSimulators() async throws -> [Simulator] {
        async let devicesJSON = Shell.run(xcrunPath, arguments: ["simctl", "list", "devices", "--json"])
        async let runtimesJSON = Shell.run(xcrunPath, arguments: ["simctl", "list", "runtimes", "--json"])

        let decoder = JSONDecoder()
        let deviceList = try decoder.decode(SimctlDeviceList.self, from: Data((try await devicesJSON).utf8))
        let runtimeList = try decoder.decode(SimctlRuntimeList.self, from: Data((try await runtimesJSON).utf8))

        let runtimeLookup = Dictionary(
            runtimeList.runtimes.map { ($0.identifier, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        var simulators: [Simulator] = []
        for (runtimeID, devices) in deviceList.devices {
            let runtimeName = runtimeLookup[runtimeID]?.name ?? friendlyRuntimeName(runtimeID)
            for device in devices {
                simulators.append(Simulator(
                    id: device.udid,
                    name: device.name,
                    state: SimulatorState(rawValue: device.state),
                    isAvailable: device.isAvailable,
                    runtime: runtimeName,
                    runtimeIdentifier: runtimeID,
                    deviceTypeIdentifier: device.deviceTypeIdentifier,
                    dataPath: device.dataPath,
                    diskSize: device.dataPathSize,
                    lastBootedAt: Formatters.parseISO8601(device.lastBootedAt)
                ))
            }
        }

        return simulators.sorted { ($0.runtime, $0.name) < ($1.runtime, $1.name) }
    }

    public func listRuntimes() async throws -> [Runtime] {
        let json = try await Shell.run(xcrunPath, arguments: ["simctl", "list", "runtimes", "--json"])
        let decoder = JSONDecoder()
        let list = try decoder.decode(SimctlRuntimeList.self, from: Data(json.utf8))
        return list.runtimes.map {
            Runtime(identifier: $0.identifier, name: $0.name, version: $0.version, isAvailable: $0.isAvailable)
        }
    }

    // MARK: - Lifecycle

    public func boot(_ simulator: Simulator) async throws {
        try await Shell.exec(xcrunPath, arguments: ["simctl", "boot", simulator.id])
    }

    public func shutdown(_ simulator: Simulator) async throws {
        try await Shell.exec(xcrunPath, arguments: ["simctl", "shutdown", simulator.id])
    }

    public func launch(_ simulator: Simulator) async throws {
        if simulator.state != .booted {
            try await boot(simulator)
        }
        try await Shell.exec("/usr/bin/open", arguments: ["-a", "Simulator", "--args", "-CurrentDeviceUDID", simulator.id])
    }

    public func reboot(_ simulator: Simulator) async throws {
        if simulator.state == .booted {
            try await shutdown(simulator)
        }
        try await boot(simulator)
    }

    // MARK: - Deletion

    public func delete(_ simulator: Simulator) async throws {
        try await Shell.exec(xcrunPath, arguments: ["simctl", "delete", simulator.id])
    }

    public func delete(_ simulators: [Simulator]) async throws {
        for simulator in simulators {
            try await delete(simulator)
        }
    }

    public func deleteUnavailable() async throws {
        try await Shell.exec(xcrunPath, arguments: ["simctl", "delete", "unavailable"])
    }

    // MARK: - Xcode

    public func isXcodeRunning() -> Bool {
        let (exitCode, _, _) = blockingRunCapturing("/usr/bin/pgrep", arguments: ["-x", "Xcode"])
        return exitCode == 0
    }

    public func closeXcode() async throws {
        try await Shell.exec("/usr/bin/killall", arguments: ["Xcode"])
    }

    // MARK: - Resolution

    /// Resolve a simulator by UDID or name from a list.
    public func resolve(_ identifier: String, from simulators: [Simulator]) throws -> Simulator {
        // Try UDID first
        if let sim = simulators.first(where: { $0.id == identifier }) {
            return sim
        }
        // Try name (case-insensitive)
        let matches = simulators.filter { $0.name.localizedCaseInsensitiveCompare(identifier) == .orderedSame }
        switch matches.count {
        case 0:
            throw SimCleanError.simulatorNotFound(identifier: identifier)
        case 1:
            return matches[0]
        default:
            throw SimCleanError.ambiguousSimulatorName(name: identifier, matches: matches)
        }
    }

    // MARK: - Private

    private func friendlyRuntimeName(_ identifier: String) -> String {
        // com.apple.CoreSimulator.SimRuntime.iOS-18-6 → iOS 18.6
        let parts = identifier.split(separator: ".")
        guard let last = parts.last else { return identifier }
        return last.replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .replacing(/(\d+) (\d+)/) { match in
                "\(match.output.1).\(match.output.2)"
            }
    }

    private func blockingRunCapturing(_ command: String, arguments: [String]) -> (exitCode: Int32, stdout: String, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return (-1, "", error.localizedDescription)
        }
        let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return (process.terminationStatus, stdout, stderr)
    }
}
