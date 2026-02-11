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
                        Task { await viewModel.purchase(tip) }
                    }
                    .disabled(viewModel.isLoading)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else if let message = viewModel.purchaseMessage {
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
        .sheet(isPresented: Binding(
            get: { viewModel.paymentURL != nil },
            set: { if !$0 { viewModel.onPaymentDismissed() } }
        )) {
            if let url = viewModel.paymentURL {
                PaymentWebView(url: url) {
                    viewModel.onPaymentReturn()
                }
                .frame(minWidth: 480, minHeight: 600)
            }
        }
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
