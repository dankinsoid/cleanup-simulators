import StoreKit

@MainActor @Observable
final class TipJarViewModel {
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var purchaseMessage: String?
    private var dismissTask: Task<Void, Never>?

    private static let productIDs = [
        "tip.small",
        "tip.medium",
        "tip.large",
    ]

    private var transactionsTask: Task<Void, Never>?

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

    func listenForTransactions() {
        guard transactionsTask == nil else { return }
        transactionsTask = Task.detached(priority: .background) {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                    await MainActor.run {
                        self.showMessage("Thank you!")
                    }
                case .unverified(let transaction, _):
                    await transaction.finish()
                }
            }
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                showMessage("Thank you!")
            case .userCancelled:
                break
            case .pending:
                showMessage("Purchase pending...")
            @unknown default:
                break
            }
        } catch {
            showMessage("Purchase failed")
        }
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
