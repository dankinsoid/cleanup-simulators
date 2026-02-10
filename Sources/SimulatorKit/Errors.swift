import Foundation

public enum SimCleanError: LocalizedError {
    case shellCommandFailed(command: String, exitCode: Int32, stderr: String)
    case simulatorNotFound(identifier: String)
    case ambiguousSimulatorName(name: String, matches: [Simulator])
    case xcodeStillRunning
    case directoryNotFound(path: String)

    public var errorDescription: String? {
        switch self {
        case .shellCommandFailed(let command, let exitCode, let stderr):
            return "Command '\(command)' failed (exit \(exitCode)): \(stderr)"
        case .simulatorNotFound(let identifier):
            return "Simulator not found: \(identifier)"
        case .ambiguousSimulatorName(let name, let matches):
            let list = matches.map { "  \($0.name) (\($0.runtime)) — \($0.id)" }.joined(separator: "\n")
            return "Multiple simulators match '\(name)':\n\(list)\nUse UDID to specify."
        case .xcodeStillRunning:
            return "Xcode is still running. Close it before proceeding."
        case .directoryNotFound(let path):
            return "Directory not found: \(path)"
        }
    }
}
