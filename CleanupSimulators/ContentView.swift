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
        .alert("Delete Simulators?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteSelected() }
            }
        } message: {
            let count = viewModel.selectedSimulatorIDs.count
            Text("Delete \(count) selected simulator(s)? This cannot be undone.")
        }
        .alert("Xcode is Running", isPresented: $viewModel.showCloseXcodeAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Continue Without Closing") {
                Task {
                    if viewModel.pendingDeleteCategory != nil {
                        await viewModel.deletePendingCategory()
                    } else if viewModel.showAutoCleanConfirmation {
                        await viewModel.autoClean()
                    } else {
                        await viewModel.deleteSelected()
                    }
                }
            }
            Button("Close Xcode & Continue", role: .destructive) {
                Task {
                    if viewModel.pendingDeleteCategory != nil {
                        await viewModel.deletePendingCategory(closeXcode: true)
                    } else if viewModel.showAutoCleanConfirmation {
                        await viewModel.autoClean(closeXcode: true)
                    } else {
                        await viewModel.deleteSelected(closeXcode: true)
                    }
                }
            }
        } message: {
            Text("Xcode is currently running. Closing Xcode is recommended before deleting simulators to avoid issues.")
        }
        .alert("Auto Clean?", isPresented: $viewModel.showAutoCleanConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clean", role: .destructive) {
                Task { await viewModel.autoClean() }
            }
        } message: {
            Text("This will delete unavailable simulators, DerivedData, Preview Simulators, IB Support, and Simulator Caches.")
        }
        .alert("Delete Category?", isPresented: $viewModel.showDeleteCategoryConfirmation) {
            Button("Cancel", role: .cancel) { viewModel.pendingDeleteCategory = nil }
            Button("Delete", role: .destructive) {
                Task { await viewModel.deletePendingCategory() }
            }
        } message: {
            if let cat = viewModel.pendingDeleteCategory {
                Text("Delete '\(cat.name)' (\(Formatters.byteCount(cat.diskSize)))? This cannot be undone.")
            }
        }
    }
}
