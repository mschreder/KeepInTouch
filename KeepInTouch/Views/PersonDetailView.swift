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
                    Spacer()
                    if let phone = person.phoneNumber, !phone.isEmpty {
                        Button {
                            call(phone)
                        } label: {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Section("Frequency") {
                FrequencyPicker(days: $person.frequencyDays)
            }

            Section("Birthday") {
                Toggle("Remind me", isOn: hasBirthdayBinding.animation())
                if hasBirthday {
                    DatePicker("Birthday", selection: birthdayDateBinding, displayedComponents: .date)
                    Text("Only the month and day are used — the year doesn't matter.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
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

    private func call(_ phoneNumber: String) {
        let digits = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty, let url = URL(string: "tel://\(digits)") else { return }
        UIApplication.shared.open(url)
    }

    private var hasBirthday: Bool {
        person.birthdayMonth != nil && person.birthdayDay != nil
    }

    private var hasBirthdayBinding: Binding<Bool> {
        Binding<Bool>(
            get: { hasBirthday },
            set: { newValue in
                if newValue {
                    let today = Calendar.current.dateComponents([.month, .day], from: Date())
                    person.birthdayMonth = today.month
                    person.birthdayDay = today.day
                } else {
                    person.birthdayMonth = nil
                    person.birthdayDay = nil
                }
                notificationService.reschedule(for: person)
            }
        )
    }

    private var birthdayDateBinding: Binding<Date> {
        Binding<Date>(
            get: {
                guard let month = person.birthdayMonth, let day = person.birthdayDay,
                      let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: day)) else {
                    return Date()
                }
                return date
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.month, .day], from: newDate)
                person.birthdayMonth = components.month
                person.birthdayDay = components.day
                notificationService.reschedule(for: person)
            }
        )
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
