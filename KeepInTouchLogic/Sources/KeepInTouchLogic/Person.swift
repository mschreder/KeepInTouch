import Foundation
import SwiftData

@Model
public final class Person {
    public var id: UUID = UUID()
    public var name: String = ""
    public var phoneNumber: String?
    public var contactIdentifier: String?
    public var photoData: Data?
    public var frequencyDays: Int = 30
    public var lastContactedAt: Date?
    public var notes: String = ""
    public var createdAt: Date = Date()

    public init(
        name: String,
        phoneNumber: String? = nil,
        contactIdentifier: String? = nil,
        photoData: Data? = nil,
        frequencyDays: Int = 30,
        lastContactedAt: Date? = nil,
        notes: String = "",
        createdAt: Date = Date()
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
    }
}
