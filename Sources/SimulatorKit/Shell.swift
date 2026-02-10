import Foundation

public enum Shell {

    /// Run a command and return stdout. Throws on non-zero exit.
    public static func run(_ command: String, arguments: [String] = []) async throws -> String {
        let (exitCode, stdout, stderr) = await runCapturing(command, arguments: arguments)
        guard exitCode == 0 else {
            throw SimCleanError.shellCommandFailed(
                command: "\(command) \(arguments.joined(separator: " "))",
                exitCode: exitCode,
                stderr: stderr
            )
        }
        return stdout
    }

    /// Run a command, discarding output. Throws on non-zero exit.
    public static func exec(_ command: String, arguments: [String] = []) async throws {
        _ = try await run(command, arguments: arguments)
    }

    /// Run a command and return (exitCode, stdout, stderr).
    public static func runCapturing(_ command: String, arguments: [String] = []) async -> (exitCode: Int32, stdout: String, stderr: String) {
        await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: command)
            process.arguments = arguments

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            process.terminationHandler = { _ in
                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                let stderr = String(data: stderrData, encoding: .utf8) ?? ""
                continuation.resume(returning: (process.terminationStatus, stdout, stderr))
            }

            do {
                try process.run()
            } catch {
                continuation.resume(returning: (-1, "", error.localizedDescription))
            }
        }
    }

    /// Resolve executable path using /usr/bin/which.
    public static func which(_ command: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [command]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return path?.isEmpty == false ? path : nil
    }
}
