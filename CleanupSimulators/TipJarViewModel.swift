import StoreKit

@MainActor @Observable
final class TipJarViewModel {
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    var purchaseMessage: String?

    private static let productIDs = [
        "tip.small",
        "tip.medium",
        "tip.large",
    ]

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            // Products unavailable
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchaseMessage = "Thank you!"
            case .userCancelled:
                break
            case .pending:
                purchaseMessage = "Purchase pending..."
            @unknown default:
                break
            }
        } catch {
            purchaseMessage = "Purchase failed"
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private enum StoreError: Error {
        case failedVerification
    }
}
