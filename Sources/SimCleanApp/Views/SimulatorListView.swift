import SwiftUI
import SimulatorKit

struct SimulatorListView: View {
    @Bindable var viewModel: SimulatorListViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.simulators.isEmpty {
                ProgressView("Loading simulators...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredSimulators.isEmpty {
                ContentUnavailableView(
                    "No Simulators",
                    systemImage: "iphone.slash",
                    description: Text(viewModel.searchText.isEmpty
                        ? "No simulators found."
                        : "No simulators match '\(viewModel.searchText)'.")
                )
            } else {
                Table(viewModel.filteredSimulators, selection: $viewModel.selectedSimulatorIDs) {
                    TableColumn("Name") { sim in
                        HStack(spacing: 6) {
                            StateBadge(state: sim.state)
                            Text(sim.name)
                        }
                    }
                    .width(min: 120, ideal: 180)

                    TableColumn("Runtime", value: \.runtime)
                        .width(min: 80, ideal: 100)

                    TableColumn("State") { sim in
                        Text(sim.state == .booted ? "Booted" : "Shutdown")
                            .foregroundStyle(sim.state == .booted ? .green : .secondary)
                    }
                    .width(min: 60, ideal: 80)

                    TableColumn("Available") { sim in
                        Image(systemName: sim.isAvailable ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(sim.isAvailable ? .green : .red)
                    }
                    .width(60)

                    TableColumn("Size") { sim in
                        Text(Formatters.byteCount(sim.diskSize))
                            .monospacedDigit()
                    }
                    .width(min: 70, ideal: 90)

                    TableColumn("Last Booted") { sim in
                        Text(Formatters.relativeDate(sim.lastBootedAt))
                            .foregroundStyle(.secondary)
                    }
                    .width(min: 100, ideal: 140)
                }
                .contextMenu(forSelectionType: String.self) { ids in
                    SimulatorContextMenu(ids: ids, viewModel: viewModel)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search simulators")
    }
}
