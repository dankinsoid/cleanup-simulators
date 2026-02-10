import SwiftUI
import SimulatorKit

struct StorageCategoryRow: View {
    let category: StorageCategory
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                Text(Formatters.byteCount(category.diskSize))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if category.diskSize > 0 {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .help("Delete \(category.name)")
            }
        }
    }
}
