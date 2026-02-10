import SwiftUI
import SimulatorKit

struct ContentView: View {
    @State private var viewModel = SimulatorListViewModel()

    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
        } detail: {
            SimulatorListView(viewModel: viewModel)
        }
        .navigationSubtitle(viewModel.subtitle)
        .toolbar {
            SimCleanToolbar(viewModel: viewModel)
        }
        .task {
            await viewModel.refresh()
        }
        .overlay(alignment: .bottom) {
            if let status = viewModel.statusMessage {
                Text(status)
                    .padding(8)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.default, value: viewModel.statusMessage)
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Delete Selected?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteSelected() }
            }
        } message: {
            let sims = viewModel.selectedSimulators.count
            let cats = viewModel.selectedCategories.count
            let totalSize = viewModel.selectedItems.reduce(0 as Int64) { $0 + $1.diskSize }
            Text("Delete \(sims + cats) item(s) (\(Formatters.byteCount(totalSize)))? This cannot be undone.")
        }
        .alert("Xcode is Running", isPresented: $viewModel.showCloseXcodeAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Continue Without Closing") {
                Task {
                    if viewModel.showAutoCleanConfirmation {
                        await viewModel.autoClean()
                    } else {
                        await viewModel.deleteSelected()
                    }
                }
            }
            Button("Close Xcode & Continue", role: .destructive) {
                Task {
                    if viewModel.showAutoCleanConfirmation {
                        await viewModel.autoClean(closeXcode: true)
                    } else {
                        await viewModel.deleteSelected(closeXcode: true)
                    }
                }
            }
        } message: {
            Text("Xcode is currently running. Closing Xcode is recommended before deleting to avoid issues.")
        }
        .alert("Auto Clean?", isPresented: $viewModel.showAutoCleanConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clean", role: .destructive) {
                Task { await viewModel.autoClean() }
            }
        } message: {
            Text("This will delete unavailable simulators, DerivedData, Preview Simulators, IB Support, and Simulator Caches.")
        }
    }
}
