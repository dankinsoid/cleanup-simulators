import ArgumentParser
import SimulatorKit

struct DeleteUnavailableCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete-unavailable",
        abstract: "Delete all unavailable simulators"
    )

    @Flag(name: .shortAndLong, help: "Skip confirmation")
    var force = false

    func run() async throws {
        let manager = SimulatorManager()

        if !force {
            let all = try await manager.listSimulators()
            let unavailable = all.filter { !$0.isAvailable }

            if unavailable.isEmpty {
                print("No unavailable simulators found.")
                return
            }

            print("Found \(unavailable.count) unavailable simulator(s):")
            for sim in unavailable {
                print("  - \(sim.name) (\(sim.runtime)) — \(Formatters.byteCount(sim.diskSize))")
            }

            if manager.isXcodeRunning() {
                print("\n⚠️  Xcode is running.")
                if Confirmation.ask("Close Xcode before deleting?", default: true) {
                    try await manager.closeXcode()
                    try await Task.sleep(for: .seconds(2))
                }
            }

            let totalSize = unavailable.reduce(Int64(0)) { $0 + $1.diskSize }
            guard Confirmation.ask("Delete all unavailable simulators (~\(Formatters.byteCount(totalSize)))?") else {
                print("Cancelled.")
                return
            }
        }

        print("Deleting unavailable simulators...")
        try await manager.deleteUnavailable()
        print("Done.")
    }
}
