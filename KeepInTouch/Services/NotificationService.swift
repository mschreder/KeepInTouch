import Foundation
import UserNotifications

@Observable
final class NotificationService {
    static let reminderHour = 18

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func reschedule(for person: Person) {
        let center = UNUserNotificationCenter.current()
        let identifier = person.id.uuidString
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

    func cancelReminder(for person: Person) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [person.id.uuidString])
    }

    func rescheduleAll(for people: [Person]) {
        for person in people {
            reschedule(for: person)
        }
    }
}
