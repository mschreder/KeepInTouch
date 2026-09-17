import SwiftUI
import SwiftData
import UIKit

struct PersonDetailView: View {
    @Bindable var person: Person
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false
    @State private var showingLogCallChoice = false
    @State private var showingLogCallDatePicker = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    avatar
                    VStack(alignment: .leading) {
                        Text(person.name).font(.organic(.title2)).foregroundStyle(Theme.ink)
                        if let phone = person.phoneNumber, !phone.isEmpty {
                            Text(phone).foregroundStyle(Theme.inkMuted)
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
            .listRowBackground(Theme.surface)

            Section("Frequency") {
                FrequencyPicker(days: $person.frequencyDays)
            }
            .listRowBackground(Theme.surface)

            Section("Birthday") {
                Toggle("Remind me", isOn: hasBirthdayBinding.animation())
                if hasBirthday {
                    DatePicker("Birthday", selection: birthdayDateBinding, displayedComponents: .date)
                    Text("Only the month and day are used — the year doesn't matter.")
                        .font(.footnote)
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .listRowBackground(Theme.surface)

            Section("Contact") {
                LabeledContent("Last called") {
                    Text(lastContactedText)
                }
                Button("Log a call now") {
                    showingLogCallChoice = true
                }
            }
            .listRowBackground(Theme.surface)

            Section("Notes") {
                TextEditor(text: $person.notes)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
            }
            .listRowBackground(Theme.surface)

            Section {
                Button("Remove from Keep In Touch", role: .destructive) {
                    showingDeleteConfirm = true
                }
            }
            .listRowBackground(Theme.surface)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
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
        .confirmationDialog(
            "Log a call with \(person.name)",
            isPresented: $showingLogCallChoice,
            titleVisibility: .visible
        ) {
            Button("Today") {
                logCall(date: Date())
            }
            Button("Choose a Date…") {
                showingLogCallDatePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingLogCallDatePicker) {
            LogCallDatePickerSheet(initialDate: person.lastContactedAt ?? Date()) { date in
                logCall(date: date)
            }
        }
    }

    private var avatar: some View {
        Group {
            if let data = person.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage).resizable()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .scaledToFill()
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        .overlay(Circle().stroke(Theme.divider, lineWidth: 1.5))
    }

    private var lastContactedText: String {
        guard let last = person.lastContactedAt else { return "Never" }
        return last.formatted(date: .abbreviated, time: .omitted)
    }

    private func logCall(date: Date) {
        person.lastContactedAt = date
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
