import Foundation
import TBCCheckout

@MainActor @Observable
final class TipJarViewModel {
    private(set) var isLoading = false
    private(set) var purchaseMessage: String?
    private(set) var paymentURL: URL?
    private var currentPayId: String?
    private var dismissTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?

    private let client: TBCCheckoutClient? = {
        let apiKey = Secrets.tbcApiKey
        let appId = Secrets.tbcAppId
        let secret = Secrets.tbcApiSecret
        guard !apiKey.isEmpty, !appId.isEmpty, !secret.isEmpty else { return nil }
        return TBCCheckoutClient(apiKey: apiKey, clientId: appId, clientSecret: secret)
    }()

    struct Tip: Identifiable {
        let id: String
        let emoji: String
        let label: String
        let amount: Decimal
        let color: String
    }

    let tips: [Tip] = [
        Tip(id: "small", emoji: "☕️", label: "$1", amount: 1, color: "orange"),
        Tip(id: "medium", emoji: "🍕", label: "$5", amount: 5, color: "pink"),
        Tip(id: "large", emoji: "🎉", label: "$10", amount: 10, color: "purple"),
    ]

    var isConfigured: Bool { client != nil }

    func purchase(_ tip: Tip) async {
        guard let client else {
            showMessage("Failed, but thank you for trying!")
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let payment = try await client.createPayment(
                TBCCreatePayment(
                    amount: Amount(currency: .usd, total: tip.amount),
                    returnURL: PaymentWebView.returnURL,
                    language: .en,
                    merchantPaymentId: "tip-\(tip.id)-\(UUID().uuidString.prefix(8))",
                    description: "Tip: \(tip.label)"
                )
            )
            currentPayId = payment.payId
            paymentURL = payment.approvalURL
        } catch {
            showMessage("Failed, but thank you for trying!")
        }
    }

    func onPaymentReturn() {
        paymentURL = nil
        guard let payId = currentPayId else { return }
        pollTask?.cancel()
        pollTask = Task {
            await checkPaymentStatus(payId)
        }
    }

    func onPaymentDismissed() {
        paymentURL = nil
        pollTask?.cancel()
        currentPayId = nil
    }

    private func checkPaymentStatus(_ payId: String) async {
        for _ in 0..<10 {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            do {
                guard let client else { return }
                let payment = try await client.getPayment(payId)
                switch payment.status {
                case .succeeded:
                    showMessage("Thank you!")
                    return
                case .failed, .expired:
                    showMessage("Failed, but thank you for trying!")
                    return
                default:
                    continue
                }
            } catch {
                continue
            }
        }
        showMessage("Thank you for trying!")
    }

    private func showMessage(_ message: String) {
        purchaseMessage = message
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                purchaseMessage = nil
            }
        }
    }
}
