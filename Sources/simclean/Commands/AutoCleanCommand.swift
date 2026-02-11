import ArgumentParser
import SimulatorKit

struct AutoCleanCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "auto-clean",
        abstract: "Run full automatic cleanup"
    )

    @Flag(name: .shortAndLong, help: "Skip confirmation")
    var force = false

    @Flag(name: .long, help: "Do not close Xcode")
    var keepXcode = false

    func run() async throws {
        let simulatorManager = SimulatorManager()
        let storageManager = StorageManager()

        if !force {
            print("Auto-clean will:")
            print("  1. Delete all unavailable simulators")
            print("  2. Remove Preview Simulators")
            print("  3. Remove DerivedData")
            print("  4. Remove IB Support data")
            print("  5. Remove Simulator Caches")

            // Show current sizes
            print("\nCalculating current storage usage...")
            let categories = await storageManager.calculateAll()
            for cat in categories {
                print("  \(cat.name): \(Formatters.byteCount(cat.diskSize))")
                if !cat.consequence.isEmpty {
                    print("    ⚠ \(cat.consequence)")
                }
            }
            let total = categories.reduce(Int64(0)) { $0 + $1.diskSize }
            print("  Total: ~\(Formatters.byteCount(total))")

            var closeXcode = false
            if !keepXcode && simulatorManager.isXcodeRunning() {
                print("\n⚠️  Xcode is running.")
                closeXcode = Confirmation.ask("Close Xcode? (required for full cleanup)", default: true)
                if !closeXcode {
                    print("Continuing without closing Xcode (some operations may fail).")
                }
            }

            guard Confirmation.ask("\nProceed with cleanup?") else {
                print("Cancelled.")
                return
            }

            print("\nCleaning up...")
            let result = try await storageManager.autoCleanup(
                simulatorManager: simulatorManager,
                closeXcode: closeXcode
            )
            printResult(result)
        } else {
            let closeXcode = !keepXcode && simulatorManager.isXcodeRunning()
            let result = try await storageManager.autoCleanup(
                simulatorManager: simulatorManager,
                closeXcode: closeXcode
            )
            printResult(result)
        }
    }

    private func printResult(_ result: CleanupResult) {
        print("\nCleanup complete!")
        if result.xcodeWasClosed {
            print("  ✓ Xcode was closed")
        }
        if result.deletedUnavailable {
            print("  ✓ Unavailable simulators deleted")
        }
        for path in result.deletedPaths {
            print("  ✓ Removed: \(path)")
        }
        print("\nFreed ~\(Formatters.byteCount(result.freedBytes))")
    }
}
