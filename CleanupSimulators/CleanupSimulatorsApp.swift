import SwiftUI

@main
struct CleanupSimulatorsApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window("Cleanup Simulators", id: "main") {
            ContentView()
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
        }
        .defaultSize(width: 900, height: 600)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: appDelegate.updaterController.updater)
            }
        }
    }
}
