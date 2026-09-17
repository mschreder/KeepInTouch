import Foundation
import UserNotifications

@Observable
final class NotificationService {
    static let reminderHour = 18

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    private func dueIdentifier(for person: Person) -> String { person.id.uuidString }
    private func birthdayIdentifier(for person: Person) -> String { "birthday-\(person.id.uuidString)" }

    func reschedule(for person: Person) {
        rescheduleDueReminder(for: person)
        rescheduleBirthdayReminder(for: person)
    }

    func cancelReminder(for person: Person) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [dueIdentifier(for: person), birthdayIdentifier(for: person)]
        )
    }

    func rescheduleAll(for people: [Person]) {
        for person in people {
            reschedule(for: person)
        }
    }

    private func rescheduleDueReminder(for person: Person) {
        let center = UNUserNotificationCenter.current()
        let identifier = dueIdentifier(for: person)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let due = OverdueCalculator.dueDate(for: person)
        var components = Calendar.current.dateComponents([.year, .month, .day], from: due)
        components.hour = Self.reminderHour

        guard let fireDate = Calendar.current.date(from: components), fireDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to call \(person.name)"
        content.body = "It's been a while — give \(person.name) a call."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    private func rescheduleBirthdayReminder(for person: Person) {
        let center = UNUserNotificationCenter.current()
        let identifier = birthdayIdentifier(for: person)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard let month = person.birthdayMonth, let day = person.birthdayDay else { return }

        var components = DateComponents()
        components.month = month
        components.day = day
        components.hour = Self.reminderHour

        let content = UNMutableNotificationContent()
        content.title = "🎂 \(person.name)'s birthday"
        content.body = "Give \(person.name) a call to celebrate."
        content.sound = .default

        // Omitting the year makes this trigger match, and repeat, every year on this date.
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }
}
