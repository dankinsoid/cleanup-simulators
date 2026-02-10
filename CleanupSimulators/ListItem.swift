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

    var simulator: Simulator? {
        if case .simulator(let s) = self { return s }
        return nil
    }

    var storageCategory: StorageCategory? {
        if case .storage(let c) = self { return c }
        return nil
    }
}
