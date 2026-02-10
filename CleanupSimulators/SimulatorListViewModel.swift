import Foundation
import SimulatorKit
import SwiftUI

@MainActor @Observable
final class SimulatorListViewModel {

    var simulators: [Simulator] = []
    var storageCategories: [StorageCategory] = []
    var isLoading = false
    var errorMessage: String?
    var selectedSimulatorIDs: Set<String> = []
    var searchText = ""
    var filterRuntime: String?

    // Alerts
    var showDeleteConfirmation = false
    var showCloseXcodeAlert = false
    var showAutoCleanConfirmation = false
    var showDeleteCategoryConfirmation = false
    var pendingDeleteCategory: StorageCategory?
    var statusMessage: String?

    let simulatorManager = SimulatorManager()
    let storageManager = StorageManager()

    var filteredSimulators: [Simulator] {
        var result = simulators
        if let filterRuntime, !filterRuntime.isEmpty {
            result = result.filter { $0.runtime == filterRuntime }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.id.localizedCaseInsensitiveContains(searchText) ||
                $0.runtime.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var runtimes: [String] {
        Array(Set(simulators.map(\.runtime))).sorted()
    }

    var totalDiskUsage: Int64 {
        simulators.reduce(0) { $0 + $1.diskSize }
    }

    var selectedSimulators: [Simulator] {
        simulators.filter { selectedSimulatorIDs.contains($0.id) }
    }

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
        guard !selectedSimulatorIDs.isEmpty else { return }
        if simulatorManager.isXcodeRunning() {
            showCloseXcodeAlert = true
        } else {
            showDeleteConfirmation = true
        }
    }

    func deleteSelected(closeXcode: Bool = false) async {
        let toDelete = selectedSimulators
        await perform("Deleting \(toDelete.count) simulator(s)...") {
            if closeXcode {
                try await self.simulatorManager.closeXcode()
                try await Task.sleep(for: .seconds(2))
            }
            try await self.simulatorManager.delete(toDelete)
        }
        selectedSimulatorIDs.removeAll()
    }

    func deleteUnavailable() async {
        await perform("Deleting unavailable simulators...") {
            try await self.simulatorManager.deleteUnavailable()
        }
    }

    func confirmDeleteCategory(_ category: StorageCategory) {
        pendingDeleteCategory = category
        if simulatorManager.isXcodeRunning() {
            showCloseXcodeAlert = true
        } else {
            showDeleteCategoryConfirmation = true
        }
    }

    func deletePendingCategory(closeXcode: Bool = false) async {
        guard let category = pendingDeleteCategory else { return }
        await perform("Deleting '\(category.name)'...") {
            if closeXcode {
                try await self.simulatorManager.closeXcode()
                try await Task.sleep(for: .seconds(2))
            }
            try self.storageManager.deleteCategory(category)
        }
        pendingDeleteCategory = nil
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
