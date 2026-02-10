import ArgumentParser
import SimulatorKit

struct RebootCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "reboot",
        abstract: "Reboot a simulator"
    )

    @Argument(help: "Simulator UDID or name")
    var simulator: String

    func run() async throws {
        let manager = SimulatorManager()
        let all = try await manager.listSimulators()
        let sim = try manager.resolve(simulator, from: all)

        print("Rebooting '\(sim.name)' (\(sim.runtime))...")
        try await manager.reboot(sim)
        print("Done.")
    }
}
