import ArgumentParser
import SimulatorKit
import Foundation

struct ListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all simulators"
    )

    @Flag(name: .shortAndLong, help: "Output as JSON")
    var json = false

    @Option(name: .shortAndLong, help: "Filter by runtime (e.g. 'iOS 18')")
    var runtime: String?

    @Flag(name: .long, help: "Show only booted simulators")
    var booted = false

    @Flag(name: .long, help: "Show only available simulators")
    var available = false

    func run() async throws {
        let manager = SimulatorManager()
        var simulators = try await manager.listSimulators()

        if let runtime {
            simulators = simulators.filter {
                $0.runtime.localizedCaseInsensitiveContains(runtime)
            }
        }
        if booted {
            simulators = simulators.filter { $0.state == .booted }
        }
        if available {
            simulators = simulators.filter { $0.isAvailable }
        }

        if json {
            printJSON(simulators)
        } else {
            printTable(simulators)
        }
    }

    private func printJSON(_ simulators: [Simulator]) {
        let items = simulators.map { sim -> [String: Any] in
            var dict: [String: Any] = [
                "udid": sim.id,
                "name": sim.name,
                "state": sim.state.rawValue,
                "isAvailable": sim.isAvailable,
                "runtime": sim.runtime,
                "diskSize": sim.diskSize,
                "diskSizeFormatted": Formatters.byteCount(sim.diskSize),
            ]
            if let date = sim.lastBootedAt {
                dict["lastBootedAt"] = ISO8601DateFormatter().string(from: date)
            }
            return dict
        }
        if let data = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
    }

    private func printTable(_ simulators: [Simulator]) {
        if simulators.isEmpty {
            print("No simulators found.")
            return
        }

        let grouped = Dictionary(grouping: simulators, by: \.runtime)
            .sorted { $0.key < $1.key }

        let table = CLITable(columns: [
            .init(header: "Name", minWidth: 20),
            .init(header: "UDID", minWidth: 36),
            .init(header: "State", minWidth: 8),
            .init(header: "Size", alignment: .right, minWidth: 10),
            .init(header: "Last Booted", minWidth: 14),
        ])

        for (runtime, sims) in grouped {
            print("\n\u{001B}[1mRuntime: \(runtime)\u{001B}[0m")
            let rows = sims.map { sim in
                [
                    sim.name,
                    sim.id,
                    sim.state == .booted ? "🟢 Booted" : "⚪ Shutdown",
                    Formatters.byteCount(sim.diskSize),
                    Formatters.relativeDate(sim.lastBootedAt),
                ]
            }
            print(table.render(rows: rows))
        }

        let totalSize = simulators.reduce(Int64(0)) { $0 + $1.diskSize }
        print("\nTotal: \(simulators.count) simulators, \(Formatters.byteCount(totalSize))")
    }
}
