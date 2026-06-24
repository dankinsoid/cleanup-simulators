import Foundation

// @ai-generated(solo)

/// One installed simulator runtime image, as reported by `simctl runtime list -j`.
///
/// Distinct from `Runtime` (which comes from `simctl list runtimes`): a `RuntimeImage`
/// is the on-disk image under `/Library/Developer/CoreSimulator` that accumulates as a
/// trail of old iOS versions after Xcode updates. It is deleted via
/// `simctl runtime delete <id>`, which reclaims the space and unmounts the image —
/// no root and no manual file removal under system paths.
struct SimctlRuntimeImage: Decodable {
    let identifier: String
    let version: String?
    let build: String?
    let kind: String?
    let deletable: Bool?
    let sizeBytes: Int64?
    let lastUsedAt: String?
    let state: String?
    let platformIdentifier: String?
}

public struct RuntimeImage: Identifiable, Sendable {
    /// The deletion UUID — the argument accepted by `simctl runtime delete`.
    public let id: String
    /// Friendly label, e.g. "iOS 15.5".
    public let name: String
    public let version: String
    public let build: String
    public let sizeBytes: Int64
    /// simctl's classification, e.g. "Legacy Download", "Cryptex Disk Image".
    public let kind: String
    public let isDeletable: Bool
    public let lastUsedAt: Date?
    public let state: String

    public init(
        id: String,
        name: String,
        version: String,
        build: String,
        sizeBytes: Int64,
        kind: String,
        isDeletable: Bool,
        lastUsedAt: Date?,
        state: String
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.build = build
        self.sizeBytes = sizeBytes
        self.kind = kind
        self.isDeletable = isDeletable
        self.lastUsedAt = lastUsedAt
        self.state = state
    }
}
