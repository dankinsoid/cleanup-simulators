import SwiftUI
import SimulatorKit

struct SimulatorListView: View {
    @Bindable var viewModel: SimulatorListViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.simulators.isEmpty {
                ProgressView("Loading simulators...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.listItems.isEmpty {
                ContentUnavailableView(
                    "No Simulators",
                    systemImage: "iphone.slash",
                    description: Text("No simulators found.")
                )
            } else {
                Table(viewModel.listItems, selection: $viewModel.selectedIDs) {
                    TableColumn("Name") { item in
                        HStack(spacing: 6) {
                            switch item {
                            case .simulator(let sim):
                                StateBadge(state: sim.state)
                                Text(sim.name)
                            case .storage(let cat):
                                Image(systemName: "folder.fill")
                                    .foregroundStyle(.orange)
                                    .font(.caption)
                                Text(cat.name)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .width(min: 120, ideal: 180)

                    TableColumn("Runtime") { item in
                        if let sim = item.simulator {
                            Text(sim.runtime)
                        }
                    }
                    .width(min: 80, ideal: 100)

                    TableColumn("State") { item in
                        if let sim = item.simulator {
                            Text(sim.state == .booted ? "Booted" : "Shutdown")
                                .foregroundStyle(sim.state == .booted ? .green : .secondary)
                        }
                    }
                    .width(min: 60, ideal: 80)

                    TableColumn("Available") { item in
                        if let sim = item.simulator {
                            Image(systemName: sim.isAvailable ? "checkmark.circle.fill" : "xmark.circle")
                                .foregroundStyle(sim.isAvailable ? .green : .red)
                        }
                    }
                    .width(60)

                    TableColumn("Size") { item in
                        Text(Formatters.byteCount(item.diskSize))
                            .monospacedDigit()
                    }
                    .width(min: 70, ideal: 90)

                    TableColumn("Last Booted") { item in
                        if let sim = item.simulator {
                            Text(Formatters.relativeDate(sim.lastBootedAt))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .width(min: 100, ideal: 140)
                }
                .contextMenu(forSelectionType: String.self) { ids in
                    SimulatorContextMenu(ids: ids, viewModel: viewModel)
                }

                if !viewModel.selectedIDs.isEmpty {
                    HStack {
                        let items = viewModel.selectedItems
                        let totalSize = items.reduce(0 as Int64) { $0 + $1.diskSize }
                        Text("\(items.count) selected — \(Formatters.byteCount(totalSize))")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
        }
    }
}
