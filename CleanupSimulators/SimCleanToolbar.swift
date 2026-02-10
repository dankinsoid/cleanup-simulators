import SwiftUI

struct SimCleanToolbar: ToolbarContent {
    @Bindable var viewModel: SimulatorListViewModel

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                Task { await viewModel.refresh() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .help("Refresh simulator list")

            Button {
                Task { await viewModel.deleteUnavailable() }
            } label: {
                Label("Delete Unavailable", systemImage: "trash.circle")
            }
            .help("Delete all unavailable simulators")

            Button {
                viewModel.confirmAutoClean()
            } label: {
                Label("Auto Clean", systemImage: "sparkles")
            }
            .help("Run full automatic cleanup")
        }

        ToolbarItem(placement: .destructiveAction) {
            if !viewModel.selectedSimulatorIDs.isEmpty {
                Button(role: .destructive) {
                    viewModel.confirmDeleteSelected()
                } label: {
                    Label("Delete Selected", systemImage: "trash")
                }
                .help("Delete \(viewModel.selectedSimulatorIDs.count) selected simulator(s)")
            }
        }
    }
}
