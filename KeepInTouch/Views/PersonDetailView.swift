import SwiftUI
import SwiftData
import UIKit

struct PersonDetailView: View {
    @Bindable var person: Person
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    avatar
                    VStack(alignment: .leading) {
                        Text(person.name).font(.title2).bold()
                        if let phone = person.phoneNumber, !phone.isEmpty {
                            Text(phone).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Frequency") {
                FrequencyPicker(days: $person.frequencyDays)
            }

            Section("Contact") {
                LabeledContent("Last called") {
                    Text(lastContactedText)
                }
                Button("Log a call now") {
                    logCall()
                }
            }

            Section("Notes") {
                TextEditor(text: $person.notes)
                    .frame(minHeight: 80)
            }

            Section {
                Button("Remove from Keep In Touch", role: .destructive) {
                    showingDeleteConfirm = true
                }
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: person.frequencyDays) { _, _ in
            notificationService.reschedule(for: person)
        }
        .confirmationDialog(
            "Remove \(person.name)?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                notificationService.cancelReminder(for: person)
                modelContext.delete(person)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var avatar: some View {
        Group {
            if let data = person.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage).resizable()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
        .scaledToFill()
        .frame(width: 60, height: 60)
        .clipShape(Circle())
    }

    private var lastContactedText: String {
        guard let last = person.lastContactedAt else { return "Never" }
        return last.formatted(date: .abbreviated, time: .omitted)
    }

    private func logCall() {
        person.lastContactedAt = Date()
        notificationService.reschedule(for: person)
    }
}

private struct FrequencyPicker: View {
    @Binding var days: Int

    private static let presets: [(String, Int)] = [
        ("Weekly", 7),
        ("Biweekly", 14),
        ("Monthly", 30),
        ("Every 2 months", 60),
        ("Every 3 months", 90),
        ("Every 6 months", 180)
    ]

    var body: some View {
        Picker("Remind me every", selection: $days) {
            ForEach(Self.presets, id: \.1) { preset in
                Text(preset.0).tag(preset.1)
            }
            if !Self.presets.map(\.1).contains(days) {
                Text("Custom (\(days) days)").tag(days)
            }
        }
        Stepper("Every \(days) day\(days == 1 ? "" : "s")", value: $days, in: 1...365)
    }
}
