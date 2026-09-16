import Testing
@testable import SimulatorKit

@Test func byteCountFormatting() {
    #expect(Formatters.byteCount(0) == "Zero KB")
    #expect(Formatters.byteCount(1024).contains("KB"))
    #expect(Formatters.byteCount(1_073_741_824).contains("GB"))
}

@Test func iso8601Parsing() {
    let date = Formatters.parseISO8601("2025-01-15T10:30:00.000Z")
    #expect(date != nil)
    #expect(Formatters.parseISO8601(nil) == nil)
    #expect(Formatters.parseISO8601("not-a-date") == nil)
}

@Test func relativeDateForNil() {
    #expect(Formatters.relativeDate(nil) == "Never")
}

@Test func simulatorStateInit() {
    #expect(SimulatorState(rawValue: "Booted") == .booted)
    #expect(SimulatorState(rawValue: "Shutdown") == .shutdown)
    #expect(SimulatorState(rawValue: "SomethingElse") == .unknown)
}

@Test func runtimeImagesCategoryIsNotFileDeletable() async {
    let categories = await StorageManager().calculateAll()
    guard let runtimes = categories.first(where: { $0.id == StorageCategory.runtimeImagesID }) else { return }
    #expect(runtimes.isDeletable == false)
    #expect(runtimes.path == StorageManager.runtimeVolumesPath)
}

@Test func deleteCategoryRejectsNonDeletable() {
    let category = StorageCategory(
        id: StorageCategory.runtimeImagesID,
        name: "Simulator Runtimes",
        path: StorageManager.runtimeVolumesPath,
        diskSize: 1,
        isDeletable: false
    )
    #expect(throws: SimCleanError.self) {
        try StorageManager().deleteCategory(category)
    }
}

@Test func autoCleanPathsExcludeRuntimeVolumes() {
    let paths = StorageManager.categories.map(\.path)
    #expect(!paths.contains { $0.hasPrefix(StorageManager.runtimeVolumesPath) })
}
