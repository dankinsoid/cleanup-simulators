import SwiftUI
import SimulatorKit

struct SidebarView: View {
    var viewModel: SimulatorListViewModel

    var body: some View {
        List {
            Section("Simulators") {
                Button {
                    viewModel.filterRuntime = nil
                } label: {
                    Label {
                        HStack {
                            Text("All")
                            Spacer()
                            Text("\(viewModel.simulators.count)")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "iphone")
                    }
                }
                .buttonStyle(.plain)
                .fontWeight(viewModel.filterRuntime == nil ? .semibold : .regular)

                ForEach(viewModel.runtimes, id: \.self) { runtime in
                    Button {
                        viewModel.filterRuntime = runtime
                    } label: {
                        Label {
                            HStack {
                                Text(runtime)
                                Spacer()
                                Text("\(viewModel.simulators.filter { $0.runtime == runtime }.count)")
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "apple.terminal")
                        }
                    }
                    .buttonStyle(.plain)
                    .fontWeight(viewModel.filterRuntime == runtime ? .semibold : .regular)
                }
            }

        }
        .listStyle(.sidebar)
    }
}
