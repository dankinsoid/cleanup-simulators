import Foundation

enum Confirmation {
    static func ask(_ message: String, default defaultValue: Bool = false) -> Bool {
        let suffix = defaultValue ? "[Y/n]" : "[y/N]"
        print("\(message) \(suffix) ", terminator: "")
        fflush(stdout)
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces).lowercased() else {
            return defaultValue
        }
        if input.isEmpty { return defaultValue }
        return input == "y" || input == "yes"
    }
}
