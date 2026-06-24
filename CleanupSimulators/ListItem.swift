import Foundation
import SimulatorKit

enum ListItem: Identifiable {
    case simulator(Simulator)
    case storage(StorageCategory)
    case runtime(RuntimeImage)

    var id: String {
        switch self {
        case .simulator(let s): s.id
        case .storage(let c): c.id
        case .runtime(let r): r.id
        }
    }

    var name: String {
        switch self {
        case .simulator(let s): s.name
        case .storage(let c): c.name
        case .runtime(let r): r.name
        }
    }

    var diskSize: Int64 {
        switch self {
        case .simulator(let s): s.diskSize
        case .storage(let c): c.diskSize
        case .runtime(let r): r.sizeBytes
        }
    }

    var runtime: String {
        simulator?.runtime ?? ""
    }

    var stateRank: Int {
        switch simulator?.state {
        case .booted: 0
        case .shutdown: 1
        default: 2
        }
    }

    var isAvailableRank: Int {
        switch simulator?.isAvailable {
        case .some(true): 0
        case .some(false): 1
        case nil: 2
        }
    }

    /// For simulators this is "last booted"; for runtime images, "last used".
    var lastBootedAt: Date {
        switch self {
        case .simulator(let s): s.lastBootedAt ?? .distantPast
        case .runtime(let r): r.lastUsedAt ?? .distantPast
        case .storage: .distantPast
        }
    }

    var simulator: Simulator? {
        if case .simulator(let s) = self { return s }
        return nil
    }

    var isCalculating: Bool {
        storageCategory?.isCalculating ?? false
    }

    var isDeletable: Bool {
        switch self {
        case .simulator: true
        case .storage(let c): c.isDeletable
        case .runtime(let r): r.isDeletable
        }
    }

    var sortGroup: Int {
        switch self {
        case .simulator: 0
        case .runtime: 1
        case .storage: 2
        }
    }

    var consequence: String {
        switch self {
        case .storage(let c): c.consequence
        case .runtime: "Simulators on this runtime stop working until it is reinstalled"
        case .simulator: ""
        }
    }

    var storageCategory: StorageCategory? {
        if case .storage(let c) = self { return c }
        return nil
    }

    var runtimeImage: RuntimeImage? {
        if case .runtime(let r) = self { return r }
        return nil
    }
}
