import Foundation

var failures = 0

func check(_ name: String, _ condition: @autoclosure () -> Bool) {
    if condition() {
        print("PASS: \(name)")
    } else {
        print("FAIL: \(name)")
        failures += 1
    }
}

let now = Date()
let cal = Calendar.current

// neverContactedUsesCreatedAtAsBaseline
do {
    let createdAt = cal.date(byAdding: .day, value: -10, to: now)!
    let person = Person(name: "Alex", frequencyDays: 14, createdAt: createdAt)
    check("neverContacted daysUntilDue == 4", OverdueCalculator.daysUntilDue(for: person, now: now) == 4)
    check("neverContacted status == onTrack", OverdueCalculator.status(for: person, now: now) == .onTrack)
}

// overdueWhenPastDueDate
do {
    let lastCalled = cal.date(byAdding: .day, value: -20, to: now)!
    let person = Person(name: "Sam", frequencyDays: 14, lastContactedAt: lastCalled)
    check("overdue daysUntilDue == -6", OverdueCalculator.daysUntilDue(for: person, now: now) == -6)
    check("overdue status == overdue", OverdueCalculator.status(for: person, now: now) == .overdue)
}

// dueSoonWithinWindow
do {
    let lastCalled = cal.date(byAdding: .day, value: -12, to: now)!
    let person = Person(name: "Jo", frequencyDays: 14, lastContactedAt: lastCalled)
    check("dueSoon daysUntilDue == 2", OverdueCalculator.daysUntilDue(for: person, now: now) == 2)
    check("dueSoon status == dueSoon", OverdueCalculator.status(for: person, now: now) == .dueSoon)
}

// exactlyOnDueDateCountsAsDueSoonNotOverdue
do {
    let lastCalled = cal.date(byAdding: .day, value: -14, to: now)!
    let person = Person(name: "Rin", frequencyDays: 14, lastContactedAt: lastCalled)
    check("onDueDate daysUntilDue == 0", OverdueCalculator.daysUntilDue(for: person, now: now) == 0)
    check("onDueDate status == dueSoon", OverdueCalculator.status(for: person, now: now) == .dueSoon)
}

// loggingACallPushesDueDateForward
do {
    let staleLastCalled = cal.date(byAdding: .day, value: -40, to: now)!
    let person = Person(name: "Priya", frequencyDays: 30, lastContactedAt: staleLastCalled)
    check("beforeLog status == overdue", OverdueCalculator.status(for: person, now: now) == .overdue)
    person.lastContactedAt = now
    check("afterLog status == onTrack", OverdueCalculator.status(for: person, now: now) == .onTrack)
    check("afterLog daysUntilDue == 30", OverdueCalculator.daysUntilDue(for: person, now: now) == 30)
}

// sortedRanksMostOverdueFirst
do {
    let onTrack = Person(name: "OnTrack", frequencyDays: 30, lastContactedAt: cal.date(byAdding: .day, value: -1, to: now)!)
    let dueSoon = Person(name: "DueSoon", frequencyDays: 14, lastContactedAt: cal.date(byAdding: .day, value: -13, to: now)!)
    let veryOverdue = Person(name: "VeryOverdue", frequencyDays: 14, lastContactedAt: cal.date(byAdding: .day, value: -60, to: now)!)
    let slightlyOverdue = Person(name: "SlightlyOverdue", frequencyDays: 14, lastContactedAt: cal.date(byAdding: .day, value: -16, to: now)!)
    let result = OverdueCalculator.sorted([onTrack, dueSoon, veryOverdue, slightlyOverdue], now: now)
    check("sorted order", result.map(\.name) == ["VeryOverdue", "SlightlyOverdue", "DueSoon", "OnTrack"])
}

// changingFrequencyShiftsDueDateImmediately
do {
    let lastCalled = cal.date(byAdding: .day, value: -10, to: now)!
    let person = Person(name: "Devon", frequencyDays: 30, lastContactedAt: lastCalled)
    check("beforeFreqChange status == onTrack", OverdueCalculator.status(for: person, now: now) == .onTrack)
    person.frequencyDays = 7
    check("afterFreqChange status == overdue", OverdueCalculator.status(for: person, now: now) == .overdue)
}

print("")
if failures == 0 {
    print("ALL CHECKS PASSED")
    exit(0)
} else {
    print("\(failures) CHECK(S) FAILED")
    exit(1)
}
