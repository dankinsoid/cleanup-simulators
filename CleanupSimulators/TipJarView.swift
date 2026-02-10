import SwiftUI
import StoreKit

struct TipJarView: View {
    @State private var viewModel = TipJarViewModel()

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)

            Text("Support Development")
                .font(.caption)
                .foregroundStyle(.secondary)

            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                HStack(spacing: 8) {
                    ForEach(viewModel.products) { product in
                        TipButton(product: product) {
                            Task { await viewModel.purchase(product) }
                        }
                    }
                }
            }

            if let message = viewModel.purchaseMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.green)
                    .transition(.opacity)
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
        .animation(.default, value: viewModel.purchaseMessage)
        .task {
            viewModel.listenForTransactions()
            await viewModel.loadProducts()
        }
    }
}

private struct TipButton: View {
    let product: Product
    let action: () -> Void
    @State private var isHovered = false

    private var emoji: String {
        switch product.id {
        case "tip.small": "☕️"
        case "tip.medium": "🍕"
        case "tip.large": "🎉"
        default: "💝"
        }
    }

    private var color: Color {
        switch product.id {
        case "tip.small": .orange
        case "tip.medium": .pink
        case "tip.large": .purple
        default: .blue
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                Text(product.displayPrice)
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
