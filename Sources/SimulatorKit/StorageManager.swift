import Foundation

public struct CleanupResult: Sendable {
    public let deletedUnavailable: Bool
    public let deletedPaths: [String]
    public let freedBytes: Int64
    public let xcodeWasClosed: Bool
}

public final class StorageManager: Sendable {
    public static let categories: [(id: String, name: String, path: String, consequence: String)] = [
        ("preview_simulators", "Preview Simulators", "~/Library/Developer/Xcode/UserData/Previews",
         "Restart Xcode and delete DerivedData, or Preview may hang"),
        ("ib_support_xcode", "IB Support", "~/Library/Developer/Xcode/IB Support",
         "Xcode will regenerate on next Interface Builder use"),
        ("ib_support_userdata", "IB Support (Old)", "~/Library/Developer/Xcode/UserData/IB Support",
         "Safe to remove, no longer used by modern Xcode"),
        ("simulator_caches", "Simulator Caches", "~/Library/Developer/CoreSimulator/Caches",
         "Xcode will rebuild caches, first simulator boot slower"),
        ("device_support", "iOS DeviceSupport", "~/Library/Developer/Xcode/iOS DeviceSupport",
         "Xcode will re-download symbols on next device connection"),
        ("derived_data", "DerivedData", "~/Library/Developer/Xcode/DerivedData",
         "All projects will require a full rebuild")
    ]

    /// Mount point of the runtime images; shown as the category path.
    ///
    /// Sizes are never measured by walking this directory: each `iOS_*` entry is a
    /// read-only APFS volume whose apparent contents are the decompressed image, several
    /// times the bytes the backing file actually occupies. simctl reports the backing size.
    public static let runtimeVolumesPath = "/Library/Developer/CoreSimulator/Volumes"

    private let simulatorManager: SimulatorManager

    public init(simulatorManager: SimulatorManager = SimulatorManager()) {
        self.simulatorManager = simulatorManager
    }

    /// Calculate disk usage for all storage categories concurrently.
    public func calculateAll() async -> [StorageCategory] {
        async let runtimeImages = runtimeImagesCategory()

        let scanned = await withTaskGroup(of: StorageCategory?.self) { group in
            for cat in Self.categories {
                group.addTask {
                    let expandedPath = NSString(string: cat.path).expandingTildeInPath
                    let size = self.directorySize(at: expandedPath)
                    return StorageCategory(
                        id: cat.id,
                        name: cat.name,
                        path: expandedPath,
                        diskSize: size,
                        consequence: cat.consequence
                    )
                }
            }
            var results: [StorageCategory] = []
            for await category in group {
                if let category { results.append(category) }
            }
            let order = Self.categories.map(\.id)
            return results.sorted { a, b in
                (order.firstIndex(of: a.id) ?? 0) < (order.firstIndex(of: b.id) ?? 0)
            }
        }

        guard let images = await runtimeImages else { return scanned }
        return scanned + [images]
    }

    /// Installed runtime images as a single reportable category.
    ///
    /// Returns nil when no images are installed or simctl is unavailable, so the category
    /// is omitted rather than reported as an empty 0-byte row.
    private func runtimeImagesCategory() async -> StorageCategory? {
        guard let images = try? await simulatorManager.listRuntimeImages(), !images.isEmpty else {
            return nil
        }
        let total = images.reduce(Int64(0)) { $0 + $1.sizeBytes }
        return StorageCategory(
            id: StorageCategory.runtimeImagesID,
            name: "Simulator Runtimes",
            path: Self.runtimeVolumesPath,
            diskSize: total,
            // Mounted system volumes; removing files here corrupts CoreSimulator.
            // Reclaimed only via `xcrun simctl runtime delete <id>`.
            isDeletable: false,
            consequence: "Delete individually with: xcrun simctl runtime delete <id>"
        )
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
        guard category.isDeletable else {
            throw SimCleanError.categoryNotDeletable(name: category.name)
        }
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

        // Calculate sizes before deletion; only the path-scanned categories get removed.
        let categories = await calculateAll()
        let totalBefore = categories
            .filter(\.isDeletable)
            .reduce(Int64(0)) { $0 + $1.diskSize }

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
