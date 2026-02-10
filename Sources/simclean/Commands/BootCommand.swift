import ArgumentParser
import SimulatorKit

struct BootCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "boot",
        abstract: "Boot a simulator"
    )

    @Argument(help: "Simulator UDID or name")
    var simulator: String

    func run() async throws {
        let manager = SimulatorManager()
        let all = try await manager.listSimulators()
        let sim = try manager.resolve(simulator, from: all)

        if sim.state == .booted {
            print("Simulator '\(sim.name)' is already booted.")
            return
        }

        print("Booting '\(sim.name)' (\(sim.runtime))...")
        try await manager.boot(sim)
        print("Done.")
    }
}
