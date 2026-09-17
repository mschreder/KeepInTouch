import Foundation
import Contacts

final class ContactsService {
    private let store = CNContactStore()

    func requestAccess() async -> Bool {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                store.requestAccess(for: .contacts) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        default:
            return false
        }
    }

    /// Re-fetches a contact with exactly the keys we need, avoiding the
    /// CNPropertyNotFetchedException risk of reading unfetched properties
    /// straight off the object the picker hands back.
    func fetchFullContact(identifier: String) throws -> CNContact? {
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
        return try store.unifiedContact(withIdentifier: identifier, keysToFetch: keys)
    }
}
