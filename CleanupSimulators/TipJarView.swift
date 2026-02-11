import SwiftUI

struct TipJarView: View {
    @State private var viewModel = TipJarViewModel()

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)

            Text("Support Development")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(viewModel.tips) { tip in
                    TipButton(tip: tip) {
                        viewModel.sponsor(tip)
                    }
                }
            }

            Spacer()

            Link(destination: URL(string: "https://github.com/dankinsoid")!) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                    Text("GitHub")
                }
                .font(.caption)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

private struct TipButton: View {
    let tip: TipJarViewModel.Tip
    let action: () -> Void
    @State private var isHovered = false

    private var color: Color {
        switch tip.color {
        case "orange": .orange
        case "pink": .pink
        case "purple": .purple
        default: .blue
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(tip.emoji)
                Text(tip.label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(isHovered ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(color.opacity(isHovered ? 0.5 : 0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .onHover { isHovered = $0 }
        }
        .buttonStyle(.plain)
    }
}
