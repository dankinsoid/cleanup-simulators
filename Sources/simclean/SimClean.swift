import ArgumentParser

@main
struct SimClean: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "simclean",
        abstract: "Manage and clean up Xcode simulators",
        subcommands: [
            ListCommand.self,
            BootCommand.self,
            ShutdownCommand.self,
            LaunchCommand.self,
            RebootCommand.self,
            DeleteCommand.self,
            DeleteUnavailableCommand.self,
            StorageCommand.self,
            AutoCleanCommand.self,
        ],
        defaultSubcommand: ListCommand.self
    )
}
