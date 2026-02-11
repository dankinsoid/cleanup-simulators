import Foundation
import SimulatorKit

enum ListItem: Identifiable {
    case simulator(Simulator)
    case storage(StorageCategory)

    var id: String {
        switch self {
        case .simulator(let s): s.id
        case .storage(let c): c.id
        }
    }

    var name: String {
        switch self {
        case .simulator(let s): s.name
        case .storage(let c): c.name
        }
    }

    var diskSize: Int64 {
        switch self {
        case .simulator(let s): s.diskSize
        case .storage(let c): c.diskSize
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

    var lastBootedAt: Date {
        simulator?.lastBootedAt ?? .distantPast
    }

    var simulator: Simulator? {
        if case .simulator(let s) = self { return s }
        return nil
    }

    var isCalculating: Bool {
        storageCategory?.isCalculating ?? false
    }

    var sortGroup: Int {
        switch self {
        case .simulator: 0
        case .storage: 1
        }
    }

    var consequence: String {
        storageCategory?.consequence ?? ""
    }

    var storageCategory: StorageCategory? {
        if case .storage(let c) = self { return c }
        return nil
    }
}
