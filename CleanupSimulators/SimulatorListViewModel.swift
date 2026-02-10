import Foundation
import SimulatorKit
import SwiftUI

@MainActor @Observable
final class SimulatorListViewModel {

    var simulators: [Simulator] = []
    var storageCategories: [StorageCategory] = []
    var isLoading = false
    var errorMessage: String?
    var selectedIDs: Set<String> = []
    var sortOrder: [KeyPathComparator<ListItem>] = [
        KeyPathComparator(\.name, order: .forward)
    ]

    // Alerts
    var showDeleteConfirmation = false
    var showCloseXcodeAlert = false
    var showAutoCleanConfirmation = false
    var statusMessage: String?

    let simulatorManager = SimulatorManager()
    let storageManager = StorageManager()

    // MARK: - Computed

    var listItems: [ListItem] {
        let sims: [ListItem] = simulators.map { .simulator($0) }
        let cats: [ListItem] = storageCategories.filter { $0.diskSize > 0 }.map { .storage($0) }
        return (sims + cats).sorted(using: sortOrder)
    }

    var selectedItems: [ListItem] {
        listItems.filter { selectedIDs.contains($0.id) }
    }

    var selectedSimulators: [Simulator] {
        selectedItems.compactMap(\.simulator)
    }

    var selectedCategories: [StorageCategory] {
        selectedItems.compactMap(\.storageCategory)
    }

    var subtitle: String {
        let items = listItems
        let totalSize = items.reduce(0 as Int64) { $0 + $1.diskSize }
        var text = "\(items.count) items — \(Formatters.byteCount(totalSize))"
        if !selectedIDs.isEmpty {
            let selected = selectedItems
            let selectedSize = selected.reduce(0 as Int64) { $0 + $1.diskSize }
            text += "  ·  \(selected.count) selected — \(Formatters.byteCount(selectedSize))"
        }
        return text
    }

    // MARK: - Actions

    func refresh() async {
        isLoading = true
        errorMessage = nil
        do {
            simulators = try await simulatorManager.listSimulators()
            storageCategories = await storageManager.calculateAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func boot(_ simulator: Simulator) async {
        await perform("Booting '\(simulator.name)'...") {
            try await self.simulatorManager.boot(simulator)
        }
    }

    func shutdown(_ simulator: Simulator) async {
        await perform("Shutting down '\(simulator.name)'...") {
            try await self.simulatorManager.shutdown(simulator)
        }
    }

    func launch(_ simulator: Simulator) async {
        await perform("Launching '\(simulator.name)'...") {
            try await self.simulatorManager.launch(simulator)
        }
    }

    func reboot(_ simulator: Simulator) async {
        await perform("Rebooting '\(simulator.name)'...") {
            try await self.simulatorManager.reboot(simulator)
        }
    }

    func confirmDeleteSelected() {
        guard !selectedIDs.isEmpty else { return }
        if simulatorManager.isXcodeRunning() {
            showCloseXcodeAlert = true
        } else {
            showDeleteConfirmation = true
        }
    }

    func deleteSelected(closeXcode: Bool = false) async {
        let sims = selectedSimulators
        let cats = selectedCategories
        let count = sims.count + cats.count
        await perform("Deleting \(count) item(s)...") {
            if closeXcode {
                try await self.simulatorManager.closeXcode()
                try await Task.sleep(for: .seconds(2))
            }
            if !sims.isEmpty {
                try await self.simulatorManager.delete(sims)
            }
            for cat in cats {
                try self.storageManager.deleteCategory(cat)
            }
        }
        selectedIDs.removeAll()
    }

    func deleteUnavailable() async {
        await perform("Deleting unavailable simulators...") {
            try await self.simulatorManager.deleteUnavailable()
        }
    }

    func confirmAutoClean() {
        if simulatorManager.isXcodeRunning() {
            showCloseXcodeAlert = true
        } else {
            showAutoCleanConfirmation = true
        }
    }

    func autoClean(closeXcode: Bool = false) async {
        await perform("Running auto-cleanup...") {
            let result = try await self.storageManager.autoCleanup(
                simulatorManager: self.simulatorManager,
                closeXcode: closeXcode
            )
            await MainActor.run {
                self.statusMessage = "Freed \(Formatters.byteCount(result.freedBytes))"
            }
        }
    }

    private func perform(_ status: String, action: @Sendable () async throws -> Void) async {
        statusMessage = status
        do {
            try await action()
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
        if statusMessage == status {
            statusMessage = nil
        }
    }
}
