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
        }
        let picker = CNContactPickerViewController()
        picker.delegate = pickerCoordinator
        topMostViewController()?.present(picker, animated: true)
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
        let person = Person(
            name: name.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            contactIdentifier: contactIdentifier,
            photoData: photoData,
            frequencyDays: frequencyDays
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
