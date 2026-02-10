import SwiftUI

@main
struct CleanupSimulatorsApp: App {
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window("Cleanup Simulators", id: "main") {
            ContentView()
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
        }
        .defaultSize(width: 900, height: 600)
    }
}
