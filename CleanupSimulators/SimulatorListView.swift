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
                Table(viewModel.listItems, selection: $viewModel.selectedIDs, sortOrder: $viewModel.sortOrder) {
                    TableColumn("Name", value: \.name) { item in
                        HStack(spacing: 6) {
                            switch item {
                            case .simulator:
                                Image(systemName: "iphone")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 14, alignment: .center)
                                Text(item.name)
                            case .storage(let cat):
                                Image(systemName: cat.id == "derived_data" ? "hammer.fill" : "internaldrive.fill")
                                    .foregroundStyle(cat.id == "derived_data" ? .blue : .orange)
                                    .frame(width: 14, alignment: .center)
                                Text(cat.name)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .width(min: 120, ideal: 180)

                    TableColumn("Runtime", value: \.runtime) { item in
                        if let sim = item.simulator {
                            Text(sim.runtime)
                        }
                    }
                    .width(min: 80, ideal: 100)

                    TableColumn("State", value: \.stateRank) { item in
                        if let sim = item.simulator {
                            HStack(spacing: 6) {
                                Text(sim.state == .booted ? "Booted" : "Shutdown")
                                    .foregroundStyle(sim.state == .booted ? .green : .secondary)
                                Spacer()
                                if sim.state == .shutdown {
                                    Button {
                                        Task { await viewModel.launch(sim) }
                                    } label: {
                                        Image(systemName: "play.fill")
                                    }
                                    .buttonStyle(InlineButtonStyle(color: .blue))
                                    .help("Run")
                                } else {
                                    Button {
                                        Task { await viewModel.shutdown(sim) }
                                    } label: {
                                        Image(systemName: "stop.fill")
                                    }
                                    .buttonStyle(InlineButtonStyle(color: .orange))
                                    .help("Shutdown")
                                }
                            }
                        }
                    }
                    .width(min: 100, ideal: 130)

                    TableColumn("Available", value: \.isAvailableRank) { item in
                        if let sim = item.simulator {
                            Image(systemName: sim.isAvailable ? "checkmark.circle.fill" : "xmark.circle")
                                .foregroundStyle(sim.isAvailable ? .green : .red)
                        }
                    }
                    .width(60)

                    TableColumn("Size", value: \.diskSize) { item in
                        HStack(spacing: 4) {
                            if item.isCalculating {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Text(Formatters.byteCount(item.diskSize))
                                    .monospacedDigit()
                            }
                            Spacer()
                            if item.diskSize > 0 {
                                Button {
                                    viewModel.selectedIDs = [item.id]
                                    viewModel.confirmDeleteSelected()
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(InlineButtonStyle(color: .red))
                                .help("Delete")
                            }
                        }
                        .frame(height: 20)
                    }
                    .width(min: 90, ideal: 110)

                    TableColumn("Last Booted", value: \.lastBootedAt) { item in
                        if let sim = item.simulator {
                            Text(Formatters.relativeDate(sim.lastBootedAt))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .width(min: 100, ideal: 140)

                    TableColumn("After Deletion", value: \.consequence) { item in
                        if !item.consequence.isEmpty {
                            Text(item.consequence)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .width(min: 180, ideal: 280)
                }
                .contextMenu(forSelectionType: String.self) { ids in
                    SimulatorContextMenu(ids: ids, viewModel: viewModel)
                }
                .scrollContentBackground(.hidden)

            }
        }
    }
}
