import AppKit
import Foundation

@MainActor @Observable
final class TipJarViewModel {

    struct Tip: Identifiable {
        let id: String
        let emoji: String
        let label: String
        let amount: Int
        let color: String
    }

    let tips: [Tip] = [
        Tip(id: "small", emoji: "☕️", label: "$1", amount: 1, color: "orange"),
        Tip(id: "medium", emoji: "🍕", label: "$5", amount: 5, color: "pink"),
        Tip(id: "large", emoji: "🎉", label: "$10", amount: 10, color: "purple"),
    ]

    func sponsor(_ tip: Tip) {
        let url = URL(string: "https://github.com/sponsors/dankinsoid/sponsorships?amount=\(tip.amount)&frequency=one_time")!
        NSWorkspace.shared.open(url)
    }
}
