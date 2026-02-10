import ArgumentParser
import SimulatorKit

struct ShutdownCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "shutdown",
        abstract: "Shutdown a simulator"
    )

    @Argument(help: "Simulator UDID or name")
    var simulator: String

    func run() async throws {
        let manager = SimulatorManager()
        let all = try await manager.listSimulators()
        let sim = try manager.resolve(simulator, from: all)

        if sim.state == .shutdown {
            print("Simulator '\(sim.name)' is already shut down.")
            return
        }

        print("Shutting down '\(sim.name)' (\(sim.runtime))...")
        try await manager.shutdown(sim)
        print("Done.")
    }
}
