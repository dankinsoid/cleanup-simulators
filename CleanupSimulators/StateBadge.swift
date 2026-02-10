import SwiftUI
import SimulatorKit

struct StateBadge: View {
    let state: SimulatorState

    var body: some View {
        Circle()
            .fill(state == .booted ? .green : .gray.opacity(0.4))
            .frame(width: 8, height: 8)
    }
}
