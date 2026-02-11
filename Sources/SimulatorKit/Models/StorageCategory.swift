import Foundation

public struct StorageCategory: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let path: String
    public let diskSize: Int64
    public let isDeletable: Bool
    public let consequence: String
    public let isCalculating: Bool

    public init(id: String, name: String, path: String, diskSize: Int64, isDeletable: Bool = true, consequence: String = "", isCalculating: Bool = false) {
        self.id = id
        self.name = name
        self.path = path
        self.diskSize = diskSize
        self.isDeletable = isDeletable
        self.consequence = consequence
        self.isCalculating = isCalculating
    }
}
