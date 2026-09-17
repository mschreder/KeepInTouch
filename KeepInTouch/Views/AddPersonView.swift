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
    @State private var showingPicker = false
    @State private var showingPermissionAlert = false

    private let contactsService = ContactsService()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        Task { await requestContact() }
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
            .sheet(isPresented: $showingPicker) {
                ContactPickerView(onPick: handlePicked, onCancel: { showingPicker = false })
            }
            .alert("Contacts Access Needed", isPresented: $showingPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Allow contacts access in Settings to pick from your address book, or just type a name below.")
            }
        }
    }

    private func requestContact() async {
        let granted = await contactsService.requestAccess()
        if granted {
            showingPicker = true
        } else {
            showingPermissionAlert = true
        }
    }

    private func handlePicked(_ contact: CNContact) {
        showingPicker = false
        contactIdentifier = contact.identifier
        if let full = try? contactsService.fetchFullContact(identifier: contact.identifier) {
            name = [full.givenName, full.familyName].filter { !$0.isEmpty }.joined(separator: " ")
            phoneNumber = full.phoneNumbers.first?.value.stringValue ?? ""
            photoData = full.thumbnailImageData
        }
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

private struct ContactPickerView: UIViewControllerRepresentable {
    var onPick: (CNContact) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onCancel: onCancel)
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        let onPick: (CNContact) -> Void
        let onCancel: () -> Void

        init(onPick: @escaping (CNContact) -> Void, onCancel: @escaping () -> Void) {
            self.onPick = onPick
            self.onCancel = onCancel
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onPick(contact)
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            onCancel()
        }
    }
}
