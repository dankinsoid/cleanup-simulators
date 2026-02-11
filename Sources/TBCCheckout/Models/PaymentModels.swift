import Foundation

// MARK: - Create Payment

public struct TBCCreatePayment: Encodable, Sendable {
    public var amount: Amount
    public var returnURL: String
    public var callbackURL: String?
    public var extra: String?
    public var extra2: String?
    public var userIpAddress: String?
    public var expirationMinutes: Int?
    public var methods: [Int]?
    public var installmentProducts: [InstallmentProduct]?
    public var preAuth: Bool?
    public var language: Language?
    public var merchantPaymentId: String?
    public var skipInfoMessage: Bool?
    public var saveCard: Bool?
    public var saveCardToDate: String?
    public var description: String?

    public init(
        amount: Amount,
        returnURL: String,
        callbackURL: String? = nil,
        language: Language? = nil,
        merchantPaymentId: String? = nil,
        preAuth: Bool? = nil,
        description: String? = nil
    ) {
        self.amount = amount
        self.returnURL = returnURL
        self.callbackURL = callbackURL
        self.language = language
        self.merchantPaymentId = merchantPaymentId
        self.preAuth = preAuth
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case amount, extra, extra2, userIpAddress, expirationMinutes, methods
        case installmentProducts, preAuth, language, merchantPaymentId
        case skipInfoMessage, saveCard, saveCardToDate, description
        case returnURL = "returnurl"
        case callbackURL = "callbackUrl"
    }
}

// MARK: - Amount

public struct Amount: Encodable, Sendable {
    public var currency: Currency
    public var total: Decimal
    public var subTotal: Decimal?
    public var tax: Decimal?
    public var shipping: Decimal?

    public init(currency: Currency, total: Decimal, subTotal: Decimal? = nil, tax: Decimal? = nil, shipping: Decimal? = nil) {
        self.currency = currency
        self.total = total
        self.subTotal = subTotal
        self.tax = tax
        self.shipping = shipping
    }
}

// MARK: - InstallmentProduct

public struct InstallmentProduct: Encodable, Sendable {
    public var name: String?
    public var price: Decimal
    public var quantity: Int

    public init(name: String? = nil, price: Decimal, quantity: Int) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case price = "Price"
        case quantity = "Quantity"
    }
}

// MARK: - Payment Response

public struct TBCPayment: Decodable, Sendable {
    public var payId: String
    public var status: PaymentStatus
    public var currency: Currency
    public var amount: Decimal
    public var confirmedAmount: Decimal?
    public var returnedAmount: Decimal?
    public var links: [Link]?
    public var transactionId: String?
    public var recId: String?
    public var preAuth: Bool?
    public var httpStatusCode: Int?
    public var developerMessage: String?
    public var userMessage: String?
    public var paymentMethod: Int?
    public var rrn: String?
    public var paymentCardNumber: String?
    public var resultCode: String?

    enum CodingKeys: String, CodingKey {
        case payId, status, currency, amount, confirmedAmount, returnedAmount
        case links, transactionId, recId, preAuth, httpStatusCode
        case developerMessage, userMessage, paymentMethod, resultCode
        case rrn = "RRN"
        case paymentCardNumber = "PaymentCardNumber"
    }

    /// URL the user should be redirected to for payment approval.
    public var approvalURL: URL? {
        links?
            .first { $0.rel == "approval_url" }
            .flatMap { URL(string: $0.uri) }
    }
}

// MARK: - Link

public struct Link: Decodable, Sendable {
    public var uri: String
    public var method: String
    public var rel: String
}

// MARK: - Cancel / Complete

public struct TBCAmountRequest: Encodable, Sendable {
    public var amount: Decimal

    public init(amount: Decimal) {
        self.amount = amount
    }
}

// MARK: - Recurring Payment

public struct TBCExecuteRecurring: Encodable, Sendable {
    public var recId: String
    public var money: Money
    public var preAuth: Bool?
    public var initiator: String?
    public var merchantPaymentId: String?
    public var extra: String?
    public var extra2: String?

    public init(recId: String, money: Money, preAuth: Bool? = nil, initiator: String? = nil) {
        self.recId = recId
        self.money = money
        self.preAuth = preAuth
        self.initiator = initiator
    }
}

public struct Money: Encodable, Sendable {
    public var amount: Decimal
    public var currency: Currency

    public init(amount: Decimal, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }
}

// MARK: - Access Token

struct TBCAccessTokenRequest: Encodable, Sendable {
    var client_Id: String
    var client_secret: String
}

public struct TBCAccessToken: Decodable, Sendable {
    public var accessToken: String
    public var tokenType: String
    public var expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

// MARK: - Enums

public enum Currency: String, Codable, Sendable {
    case gel = "GEL"
    case usd = "USD"
    case eur = "EUR"
}

public enum Language: String, Encodable, Sendable {
    case ka = "KA"
    case en = "EN"
}

public enum PaymentStatus: String, Decodable, Sendable {
    case created = "Created"
    case processing = "Processing"
    case succeeded = "Succeeded"
    case failed = "Failed"
    case expired = "Expired"
    case waitingConfirm = "WaitingConfirm"
    case cancelPaymentProcessing = "CancelPaymentProcessing"
    case paymentCompletionProcessing = "PaymentCompletionProcessing"
    case returned = "Returned"
    case partialReturned = "PartialReturned"
    case unknown

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = PaymentStatus(rawValue: value) ?? .unknown
    }

    /// Whether this status is final (no further changes expected).
    public var isFinal: Bool {
        switch self {
        case .succeeded, .failed, .expired: true
        default: false
        }
    }
}

// MARK: - Error

public struct TBCError: Decodable, Error, Sendable {
    public var type: String?
    public var title: String?
    public var status: String?
    public var systemCode: String?
    public var detail: String?
    public var resultCode: String?
}
