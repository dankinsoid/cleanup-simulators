import SwiftUI
import StoreKit

struct TipJarView: View {
    @State private var viewModel = TipJarViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.largeTitle)
                .foregroundStyle(.pink)

            Text("Support Development")
                .font(.headline)

            Text("If you find this app useful, consider leaving a tip!")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 80)
            } else if viewModel.products.isEmpty {
                Text("Tips unavailable")
                    .foregroundStyle(.secondary)
                    .frame(height: 80)
            } else {
                HStack(spacing: 12) {
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

            Divider()

            Link(destination: URL(string: "https://github.com/dankinsoid")!) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                    Text("GitHub")
                }
                .font(.caption)
            }
        }
        .padding(20)
        .frame(width: 260)
        .animation(.default, value: viewModel.purchaseMessage)
        .task {
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
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.title2)
                Text(product.displayPrice)
                    .font(.headline)
                    .fontDesign(.rounded)
            }
            .frame(width: 68, height: 68)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isHovered ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
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
