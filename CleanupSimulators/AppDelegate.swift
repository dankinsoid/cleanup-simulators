import AppKit
import Sparkle

final class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {

    let updaterController = SPUStandardUpdaterController(
        startingUpdater: false,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            try updaterController.updater.start()
        } catch {}

        if let window = NSApplication.shared.windows.first {
            window.setFrameAutosaveName("MainWindow")
        }
    }
}
