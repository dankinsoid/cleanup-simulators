import ArgumentParser
import SimulatorKit

struct DeleteCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete simulator(s)"
    )

    @Argument(help: "Simulator UDID(s) or name(s)")
    var simulators: [String]

    @Flag(name: .shortAndLong, help: "Skip confirmation")
    var force = false

    func run() async throws {
        let manager = SimulatorManager()
        let all = try await manager.listSimulators()

        let resolved = try simulators.map { try manager.resolve($0, from: all) }

        if !force {
            print("The following simulators will be deleted:")
            for sim in resolved {
                print("  - \(sim.name) (\(sim.runtime)) — \(Formatters.byteCount(sim.diskSize))")
            }

            if manager.isXcodeRunning() {
                print("\n⚠️  Xcode is running.")
                if Confirmation.ask("Close Xcode before deleting?", default: true) {
                    try await manager.closeXcode()
                    try await Task.sleep(for: .seconds(2))
                }
            }

            guard Confirmation.ask("Delete \(resolved.count) simulator(s)?") else {
                print("Cancelled.")
                return
            }
        }

        for sim in resolved {
            print("Deleting '\(sim.name)'...")
            try await manager.delete(sim)
        }

        let totalFreed = resolved.reduce(Int64(0)) { $0 + $1.diskSize }
        print("Done. Freed ~\(Formatters.byteCount(totalFreed)).")
    }
}
