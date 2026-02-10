import SwiftUI

struct SimCleanToolbar: ToolbarContent {
    @Bindable var viewModel: SimulatorListViewModel
    @State private var showTipJar = false

    private var hasSelection: Bool {
        !viewModel.selectedIDs.isEmpty
    }

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                showTipJar.toggle()
            } label: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
            }
            .help("Support Development")
            .popover(isPresented: $showTipJar) {
                TipJarView()
            }
        }

        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                Task { await viewModel.refresh() }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
            }
            .help("Refresh simulator list")

            Button {
                Task { await viewModel.deleteUnavailable() }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash.circle")
                    Text("Delete Unavailable")
                }
            }
            .help("Delete all unavailable simulators")

            Button {
                viewModel.confirmAutoClean()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                    Text("Auto Clean")
                }
            }
            .help("Run full automatic cleanup")

            Button(role: .destructive) {
                viewModel.confirmDeleteSelected()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
            .disabled(!hasSelection)
            .help(hasSelection
                ? "Delete \(viewModel.selectedIDs.count) selected simulator(s)"
                : "Select simulators to delete")
        }
    }
}
