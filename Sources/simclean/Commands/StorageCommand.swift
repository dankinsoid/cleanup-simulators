import ArgumentParser
import Foundation
import SimulatorKit

struct StorageCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "storage",
        abstract: "Show storage usage by category"
    )

    @Flag(name: .shortAndLong, help: "Output as JSON")
    var json = false

    func run() async throws {
        let storageManager = StorageManager()
        let categories = await storageManager.calculateAll()

        if json {
            printJSON(categories)
        } else {
            printTable(categories)
        }
    }

    private func printJSON(_ categories: [StorageCategory]) {
        let items = categories.map { cat -> [String: Any] in
            [
                "id": cat.id,
                "name": cat.name,
                "path": cat.path,
                "diskSize": cat.diskSize,
                "diskSizeFormatted": Formatters.byteCount(cat.diskSize),
            ]
        }
        if let data = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
    }

    private func printTable(_ categories: [StorageCategory]) {
        let table = CLITable(columns: [
            .init(header: "Category", minWidth: 25),
            .init(header: "Size", alignment: .right, minWidth: 12),
            .init(header: "Path"),
        ])

        let rows = categories.map { cat in
            [cat.name, Formatters.byteCount(cat.diskSize), cat.path]
        }

        print(table.render(rows: rows))

        let total = categories.reduce(Int64(0)) { $0 + $1.diskSize }
        print(String(repeating: "─", count: 60))
        print("Total: \(Formatters.byteCount(total))")
    }
}
