import Foundation

public struct CleanupResult: Sendable {
    public let deletedUnavailable: Bool
    public let deletedPaths: [String]
    public let freedBytes: Int64
    public let xcodeWasClosed: Bool
}

public final class StorageManager: Sendable {

    public static let categories: [(id: String, name: String, path: String)] = [
        ("preview_simulators",  "Preview Simulators",   "~/Library/Developer/Xcode/UserData/Previews"),
        ("ib_support_xcode",    "IB Support",           "~/Library/Developer/Xcode/IB Support"),
        ("ib_support_userdata", "IB Support (UserData)","~/Library/Developer/Xcode/UserData/IB Support"),
        ("derived_data",        "DerivedData",          "~/Library/Developer/Xcode/DerivedData"),
        ("simulator_caches",    "Simulator Caches",     "~/Library/Developer/CoreSimulator/Caches"),
    ]

    public init() {}

    /// Calculate disk usage for all storage categories concurrently.
    public func calculateAll() async -> [StorageCategory] {
        await withTaskGroup(of: StorageCategory?.self) { group in
            for cat in Self.categories {
                group.addTask {
                    let expandedPath = NSString(string: cat.path).expandingTildeInPath
                    let size = self.directorySize(at: expandedPath)
                    return StorageCategory(
                        id: cat.id,
                        name: cat.name,
                        path: expandedPath,
                        diskSize: size
                    )
                }
            }
            var results: [StorageCategory] = []
            for await category in group {
                if let category { results.append(category) }
            }
            return results.sorted { $0.diskSize > $1.diskSize }
        }
    }

    /// Calculate directory size using FileManager.
    public func directorySize(at path: String) -> Int64 {
        let fm = FileManager.default
        let url = URL(fileURLWithPath: path)

        guard fm.fileExists(atPath: path) else { return 0 }

        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return 0 }

        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .isRegularFileKey]),
                  values.isRegularFile == true,
                  let size = values.totalFileAllocatedSize else { continue }
            totalSize += Int64(size)
        }
        return totalSize
    }

    /// Delete a storage category directory.
    public func deleteCategory(_ category: StorageCategory) throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: category.path) else {
            throw SimCleanError.directoryNotFound(path: category.path)
        }
        try fm.removeItem(atPath: category.path)
    }

    /// Full auto-cleanup.
    public func autoCleanup(simulatorManager: SimulatorManager, closeXcode: Bool) async throws -> CleanupResult {
        var xcodeWasClosed = false

        if closeXcode && simulatorManager.isXcodeRunning() {
            try await simulatorManager.closeXcode()
            xcodeWasClosed = true
            // Give Xcode a moment to fully quit
            try await Task.sleep(for: .seconds(2))
        }

        // Delete unavailable simulators
        try await simulatorManager.deleteUnavailable()

        // Calculate sizes before deletion
        let categories = await calculateAll()
        let totalBefore = categories.reduce(Int64(0)) { $0 + $1.diskSize }

        // Delete category directories
        let fm = FileManager.default
        var deletedPaths: [String] = []
        let pathsToClean = Self.categories.map { NSString(string: $0.path).expandingTildeInPath }

        for path in pathsToClean {
            if fm.fileExists(atPath: path) {
                try? fm.removeItem(atPath: path)
                deletedPaths.append(path)
            }
        }

        return CleanupResult(
            deletedUnavailable: true,
            deletedPaths: deletedPaths,
            freedBytes: totalBefore,
            xcodeWasClosed: xcodeWasClosed
        )
    }
}
