import Foundation
import SwiftData

@Model
final class Person {
    var id: UUID = UUID()
    var name: String = ""
    var phoneNumber: String?
    var contactIdentifier: String?
    var photoData: Data?
    var frequencyDays: Int = 30
    var lastContactedAt: Date?
    var notes: String = ""
    var createdAt: Date = Date()
    var birthdayMonth: Int?
    var birthdayDay: Int?

    init(
        name: String,
        phoneNumber: String? = nil,
        contactIdentifier: String? = nil,
        photoData: Data? = nil,
        frequencyDays: Int = 30,
        lastContactedAt: Date? = nil,
        notes: String = "",
        createdAt: Date = Date(),
        birthdayMonth: Int? = nil,
        birthdayDay: Int? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.phoneNumber = phoneNumber
        self.contactIdentifier = contactIdentifier
        self.photoData = photoData
        self.frequencyDays = frequencyDays
        self.lastContactedAt = lastContactedAt
        self.notes = notes
        self.createdAt = createdAt
        self.birthdayMonth = birthdayMonth
        self.birthdayDay = birthdayDay
    }
}
