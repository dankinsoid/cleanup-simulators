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

    @Flag(name: .long, help: "List each installed runtime image individually")
    var runtimes = false

    func run() async throws {
        let simulatorManager = SimulatorManager()
        let storageManager = StorageManager(simulatorManager: simulatorManager)
        let categories = await storageManager.calculateAll()
        let images = (try? await simulatorManager.listRuntimeImages()) ?? []

        if json {
            printJSON(categories, images: images)
        } else {
            printTable(categories)
            if runtimes {
                printRuntimes(images)
            }
        }
    }

    private func printJSON(_ categories: [StorageCategory], images: [RuntimeImage]) {
        let items = categories.map { cat -> [String: Any] in
            var item: [String: Any] = [
                "id": cat.id,
                "name": cat.name,
                "path": cat.path,
                "diskSize": cat.diskSize,
                "diskSizeFormatted": Formatters.byteCount(cat.diskSize),
                "isDeletable": cat.isDeletable,
            ]
            if cat.id == StorageCategory.runtimeImagesID {
                item["runtimes"] = images.map { img in
                    [
                        "id": img.id,
                        "name": img.name,
                        "build": img.build,
                        "kind": img.kind,
                        "state": img.state,
                        "isDeletable": img.isDeletable,
                        "diskSize": img.sizeBytes,
                        "diskSizeFormatted": Formatters.byteCount(img.sizeBytes),
                    ]
                }
            }
            return item
        }
        if let data = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
    }

    private func printRuntimes(_ images: [RuntimeImage]) {
        guard !images.isEmpty else { return }

        let table = CLITable(columns: [
            .init(header: "Runtime", minWidth: 16),
            .init(header: "Build", minWidth: 8),
            .init(header: "Size", alignment: .right, minWidth: 12),
            .init(header: "Last Used", minWidth: 16),
            .init(header: "Identifier"),
        ])

        let rows = images.map { img in
            [img.name, img.build, Formatters.byteCount(img.sizeBytes), Formatters.relativeDate(img.lastUsedAt), img.id]
        }

        print("\nSimulator Runtimes")
        print(table.render(rows: rows))
        print("\nRemove with: xcrun simctl runtime delete <identifier>")
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
        let reclaimable = categories.filter(\.isDeletable).reduce(Int64(0)) { $0 + $1.diskSize }
        print(String(repeating: "─", count: 60))
        print("Total: \(Formatters.byteCount(total))")
        if reclaimable != total {
            print("Removable by auto-clean: \(Formatters.byteCount(reclaimable))")
        }
    }
}
