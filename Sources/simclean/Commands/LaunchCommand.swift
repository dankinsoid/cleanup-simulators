import ArgumentParser
import SimulatorKit

struct LaunchCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "launch",
        abstract: "Launch a simulator in Simulator.app"
    )

    @Argument(help: "Simulator UDID or name")
    var simulator: String

    func run() async throws {
        let manager = SimulatorManager()
        let all = try await manager.listSimulators()
        let sim = try manager.resolve(simulator, from: all)

        print("Launching '\(sim.name)' (\(sim.runtime))...")
        try await manager.launch(sim)
        print("Done.")
    }
}
