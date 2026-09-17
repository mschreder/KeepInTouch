import Foundation
import Testing
@testable import KeepInTouchLogic

@Suite struct OverdueCalculatorTests {

    @Test func neverContactedUsesCreatedAtAsBaseline() {
        let now = Date()
        let createdAt = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        let person = Person(name: "Alex", frequencyDays: 14, createdAt: createdAt)

        #expect(OverdueCalculator.daysUntilDue(for: person, now: now) == 4)
        #expect(OverdueCalculator.status(for: person, now: now) == .onTrack)
    }

    @Test func overdueWhenPastDueDate() {
        let now = Date()
        let lastCalled = Calendar.current.date(byAdding: .day, value: -20, to: now)!
        let person = Person(name: "Sam", frequencyDays: 14, lastContactedAt: lastCalled)

        #expect(OverdueCalculator.daysUntilDue(for: person, now: now) == -6)
        #expect(OverdueCalculator.status(for: person, now: now) == .overdue)
    }

    @Test func dueSoonWithinWindow() {
        let now = Date()
        let lastCalled = Calendar.current.date(byAdding: .day, value: -12, to: now)!
        let person = Person(name: "Jo", frequencyDays: 14, lastContactedAt: lastCalled)

        // 2 days until due, within the 3-day "due soon" window
        #expect(OverdueCalculator.daysUntilDue(for: person, now: now) == 2)
        #expect(OverdueCalculator.status(for: person, now: now) == .dueSoon)
    }

    @Test func exactlyOnDueDateCountsAsDueSoonNotOverdue() {
        let now = Date()
        let lastCalled = Calendar.current.date(byAdding: .day, value: -14, to: now)!
        let person = Person(name: "Rin", frequencyDays: 14, lastContactedAt: lastCalled)

        #expect(OverdueCalculator.daysUntilDue(for: person, now: now) == 0)
        #expect(OverdueCalculator.status(for: person, now: now) == .dueSoon)
    }

    @Test func loggingACallPushesDueDateForward() {
        let now = Date()
        let staleLastCalled = Calendar.current.date(byAdding: .day, value: -40, to: now)!
        let person = Person(name: "Priya", frequencyDays: 30, lastContactedAt: staleLastCalled)
        #expect(OverdueCalculator.status(for: person, now: now) == .overdue)

        person.lastContactedAt = now
        #expect(OverdueCalculator.status(for: person, now: now) == .onTrack)
        #expect(OverdueCalculator.daysUntilDue(for: person, now: now) == 30)
    }

    @Test func sortedRanksMostOverdueFirst() {
        let now = Date()
        let onTrack = Person(
            name: "OnTrack",
            frequencyDays: 30,
            lastContactedAt: Calendar.current.date(byAdding: .day, value: -1, to: now)!
        )
        let dueSoon = Person(
            name: "DueSoon",
            frequencyDays: 14,
            lastContactedAt: Calendar.current.date(byAdding: .day, value: -13, to: now)!
        )
        let veryOverdue = Person(
            name: "VeryOverdue",
            frequencyDays: 14,
            lastContactedAt: Calendar.current.date(byAdding: .day, value: -60, to: now)!
        )
        let slightlyOverdue = Person(
            name: "SlightlyOverdue",
            frequencyDays: 14,
            lastContactedAt: Calendar.current.date(byAdding: .day, value: -16, to: now)!
        )

        let result = OverdueCalculator.sorted([onTrack, dueSoon, veryOverdue, slightlyOverdue], now: now)

        #expect(result.map(\.name) == ["VeryOverdue", "SlightlyOverdue", "DueSoon", "OnTrack"])
    }

    @Test func changingFrequencyShiftsDueDateImmediately() {
        let now = Date()
        let lastCalled = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        let person = Person(name: "Devon", frequencyDays: 30, lastContactedAt: lastCalled)
        #expect(OverdueCalculator.status(for: person, now: now) == .onTrack)

        // Tightening the cadence to weekly should immediately flip this to overdue.
        person.frequencyDays = 7
        #expect(OverdueCalculator.status(for: person, now: now) == .overdue)
    }
}
