import Foundation

struct SimctlRuntimeList: Decodable {
    let runtimes: [SimctlRuntime]
}

struct SimctlRuntime: Decodable {
    let identifier: String
    let name: String
    let version: String
    let isAvailable: Bool
}

public struct Runtime: Identifiable, Sendable {
    public var id: String { identifier }
    public let identifier: String
    public let name: String
    public let version: String
    public let isAvailable: Bool
}
