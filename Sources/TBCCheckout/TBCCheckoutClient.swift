import Foundation
import SwiftAPIClient

public struct TBCCheckoutClient {

    private let client: APIClient

    public init(
        apiKey: String,
        clientId: String,
        clientSecret: String,
        baseURL: URL = URL(string: "https://api.tbcbank.ge/v1")!
    ) {
        client = APIClient(baseURL: baseURL)
            .bodyEncoder(.json(dateEncodingStrategy: .iso8601))
            .bodyDecoder(.json(dateDecodingStrategy: .iso8601))
            .errorDecoder(.decodable(TBCError.self))
            .header("apikey", apiKey)
            .tokenRefresher { _, client, _ in
                let token: TBCAccessToken = try await client("tpay", "access-token")
                    .body([
                        "client_Id": clientId,
                        "client_secret": clientSecret,
                    ])
                    .bodyEncoder(.formURL)
                    .post()
                return (token.accessToken, nil, Date(timeIntervalSinceNow: TimeInterval(token.expiresIn)))
            } auth: {
                .bearer(token: $0)
            }
    }

    // MARK: - Payments

    /// Create a new payment and get the approval URL.
    public func createPayment(_ request: TBCCreatePayment) async throws -> TBCPayment {
        try await client("tpay", "payments")
            .body(request)
            .post()
    }

    /// Get payment details by payment ID.
    public func getPayment(_ payId: String) async throws -> TBCPayment {
        try await client("tpay", "payments", payId)
            .get()
    }

    /// Cancel (refund) a payment. Pass the amount to partially refund.
    public func cancelPayment(_ payId: String, amount: Decimal) async throws -> TBCPayment {
        try await client("tpay", "payments", payId, "cancel")
            .body(TBCAmountRequest(amount: amount))
            .post()
    }

    /// Complete a pre-authorized payment.
    public func completePayment(_ payId: String, amount: Decimal) async throws -> TBCPayment {
        try await client("tpay", "payments", payId, "completion")
            .body(TBCAmountRequest(amount: amount))
            .post()
    }

    // MARK: - Recurring

    /// Execute a recurring payment using a saved card.
    public func executeRecurring(_ request: TBCExecuteRecurring) async throws -> TBCPayment {
        try await client("tpay", "payments", "execution")
            .body(request)
            .post()
    }

    /// Delete a saved recurring card.
    public func deleteRecurring(_ recId: String) async throws {
        try await client("tpay", "payments", recId, "delete")
            .post()
    }
}
