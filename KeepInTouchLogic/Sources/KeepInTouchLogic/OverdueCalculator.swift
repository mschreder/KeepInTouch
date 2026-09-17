import Foundation

public enum ContactStatus: Equatable {
    case overdue
    case dueSoon
    case onTrack
}

public enum OverdueCalculator {
    public static let dueSoonWindowDays = 3

    public static func dueDate(for person: Person) -> Date {
        let referenceDate = person.lastContactedAt ?? person.createdAt
        return Calendar.current.date(byAdding: .day, value: person.frequencyDays, to: referenceDate) ?? referenceDate
    }

    public static func daysUntilDue(for person: Person, now: Date = Date()) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let due = calendar.startOfDay(for: dueDate(for: person))
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }

    public static func status(for person: Person, now: Date = Date()) -> ContactStatus {
        let daysLeft = daysUntilDue(for: person, now: now)
        if daysLeft < 0 {
            return .overdue
        } else if daysLeft <= dueSoonWindowDays {
            return .dueSoon
        } else {
            return .onTrack
        }
    }

    public static func sorted(_ people: [Person], now: Date = Date()) -> [Person] {
        people.sorted { daysUntilDue(for: $0, now: now) < daysUntilDue(for: $1, now: now) }
    }
}
