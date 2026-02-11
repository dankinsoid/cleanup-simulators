import AppKit
import Sparkle

final class AppDelegate: NSObject, NSApplicationDelegate {

    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
}
