import SwiftUI
import SwiftData
import Contacts
import ContactsUI
import UIKit

struct AddPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var photoData: Data?
    @State private var contactIdentifier: String?
    @State private var frequencyDays = 30
    @State private var hasBirthday = false
    @State private var birthdayDate = Date()
    @State private var pickerCoordinator = ContactPickerCoordinator()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        presentContactPicker()
                    } label: {
                        Label("Choose from Contacts", systemImage: "person.crop.circle.badge.plus")
                    }
                }

                Section("Details") {
                    TextField("Name", text: $name)
                    TextField("Phone (optional)", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section("Frequency") {
                    Picker("Remind me every", selection: $frequencyDays) {
                        Text("Weekly").tag(7)
                        Text("Biweekly").tag(14)
                        Text("Monthly").tag(30)
                        Text("Every 2 months").tag(60)
                        Text("Every 3 months").tag(90)
                        Text("Every 6 months").tag(180)
                    }
                }

                Section("Birthday") {
                    Toggle("Remind me on their birthday", isOn: $hasBirthday.animation())
                    if hasBirthday {
                        DatePicker("Birthday", selection: $birthdayDate, displayedComponents: .date)
                        Text("Only the month and day are used — the year doesn't matter.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func presentContactPicker() {
        pickerCoordinator.onPick = { contact in
            contactIdentifier = contact.identifier
            name = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
            phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
            photoData = contact.thumbnailImageData
            fetchBirthday(forContactIdentifier: contact.identifier)
        }
        let picker = CNContactPickerViewController()
        picker.delegate = pickerCoordinator
        topMostViewController()?.present(picker, animated: true)
    }

    /// Birthday isn't part of the small set of properties the picker hands back
    /// directly, so it needs its own permissioned fetch. Best-effort: if access
    /// isn't granted or the contact has no birthday on file, we just leave the
    /// field for the user to fill in themselves.
    private func fetchBirthday(forContactIdentifier identifier: String) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            guard granted else { return }
            let keys = [CNContactBirthdayKey as CNKeyDescriptor]
            guard let contact = try? store.unifiedContact(withIdentifier: identifier, keysToFetch: keys),
                  let birthday = contact.birthday,
                  let month = birthday.month,
                  let day = birthday.day,
                  let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: day)) else {
                return
            }
            DispatchQueue.main.async {
                hasBirthday = true
                birthdayDate = date
            }
        }
    }

    private func topMostViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }

    private func save() {
        let birthdayComponents = hasBirthday ? Calendar.current.dateComponents([.month, .day], from: birthdayDate) : nil
        let person = Person(
            name: name.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            contactIdentifier: contactIdentifier,
            photoData: photoData,
            frequencyDays: frequencyDays,
            birthdayMonth: birthdayComponents?.month,
            birthdayDay: birthdayComponents?.day
        )
        modelContext.insert(person)
        notificationService.reschedule(for: person)
        dismiss()
    }
}

private final class ContactPickerCoordinator: NSObject, CNContactPickerDelegate {
    var onPick: ((CNContact) -> Void)?

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        onPick?(contact)
    }
}
