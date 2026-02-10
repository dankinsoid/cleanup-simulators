import SwiftUI
import SimulatorKit

struct SimulatorContextMenu: View {
    let ids: Set<String>
    @Bindable var viewModel: SimulatorListViewModel

    private var items: [ListItem] {
        viewModel.listItems.filter { ids.contains($0.id) }
    }

    private var singleSimulator: Simulator? {
        guard items.count == 1 else { return nil }
        return items.first?.simulator
    }

    var body: some View {
        if let sim = singleSimulator {
            if sim.state == .shutdown {
                Button("Boot") {
                    Task { await viewModel.boot(sim) }
                }
                Button("Launch in Simulator") {
                    Task { await viewModel.launch(sim) }
                }
            } else {
                Button("Shutdown") {
                    Task { await viewModel.shutdown(sim) }
                }
                Button("Reboot") {
                    Task { await viewModel.reboot(sim) }
                }
            }
            Divider()
        }

        Button("Delete \(items.count > 1 ? "\(items.count) Items" : "")", role: .destructive) {
            viewModel.selectedIDs = ids
            viewModel.confirmDeleteSelected()
        }
    }
}
