import SwiftUI
import SimulatorKit

struct SimulatorContextMenu: View {
    let ids: Set<String>
    @Bindable var viewModel: SimulatorListViewModel

    private var simulators: [Simulator] {
        viewModel.simulators.filter { ids.contains($0.id) }
    }

    private var single: Simulator? {
        simulators.count == 1 ? simulators.first : nil
    }

    var body: some View {
        if let sim = single {
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

        Button("Delete \(simulators.count > 1 ? "\(simulators.count) Simulators" : "Simulator")", role: .destructive) {
            viewModel.selectedSimulatorIDs = ids
            viewModel.confirmDeleteSelected()
        }
    }
}
