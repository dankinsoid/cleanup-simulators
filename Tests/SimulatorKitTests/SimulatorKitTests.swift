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
