import Foundation

// MARK: - simctl JSON models

struct SimctlDeviceList: Decodable {
    let devices: [String: [SimctlDevice]]
}

struct SimctlDevice: Decodable {
    let udid: String
    let name: String
    let state: String
    let isAvailable: Bool
    let deviceTypeIdentifier: String
    let dataPath: String
    let dataPathSize: Int64
    let logPath: String
    let logPathSize: Int64
    let lastBootedAt: String?
}

// MARK: - Domain model

public enum SimulatorState: String, Sendable, Codable {
    case booted = "Booted"
    case shutdown = "Shutdown"
    case unknown

    public init(rawValue: String) {
        switch rawValue {
        case "Booted": self = .booted
        case "Shutdown": self = .shutdown
        default: self = .unknown
        }
    }
}

public struct Simulator: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let state: SimulatorState
    public let isAvailable: Bool
    public let runtime: String
    public let runtimeIdentifier: String
    public let deviceTypeIdentifier: String
    public let dataPath: String
    public let diskSize: Int64
    public let lastBootedAt: Date?

    public init(
        id: String,
        name: String,
        state: SimulatorState,
        isAvailable: Bool,
        runtime: String,
        runtimeIdentifier: String,
        deviceTypeIdentifier: String,
        dataPath: String,
        diskSize: Int64,
        lastBootedAt: Date?
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.isAvailable = isAvailable
        self.runtime = runtime
        self.runtimeIdentifier = runtimeIdentifier
        self.deviceTypeIdentifier = deviceTypeIdentifier
        self.dataPath = dataPath
        self.diskSize = diskSize
        self.lastBootedAt = lastBootedAt
    }
}
