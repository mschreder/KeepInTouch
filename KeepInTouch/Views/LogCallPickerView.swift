import SwiftUI
import SwiftData

/// The general "log a call" flow from the main screen: pick who you called,
/// then whether it was today or another day.
struct LogCallPickerView: View {
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.dismiss) private var dismiss
    @Query private var people: [Person]

    @State private var selectedPerson: Person?
    @State private var showingDateChoice = false
    @State private var showingCustomDatePicker = false

    private var sortedPeople: [Person] {
        OverdueCalculator.sorted(people)
    }

    var body: some View {
        NavigationStack {
            List {
                if people.isEmpty {
                    Text("Add people first to log calls.")
                        .foregroundStyle(Theme.inkMuted)
                } else {
                    ForEach(sortedPeople) { person in
                        Button {
                            selectedPerson = person
                            showingDateChoice = true
                        } label: {
                            PersonRowView(person: person)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Theme.surface)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Who did you call?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .confirmationDialog(
                dateChoiceTitle,
                isPresented: $showingDateChoice,
                titleVisibility: .visible
            ) {
                Button("Today") {
                    logCall(date: Date())
                }
                Button("Choose a Date…") {
                    showingCustomDatePicker = true
                }
                Button("Cancel", role: .cancel) {
                    selectedPerson = nil
                }
            }
            .sheet(isPresented: $showingCustomDatePicker) {
                if let person = selectedPerson {
                    LogCallDatePickerSheet(initialDate: person.lastContactedAt ?? Date()) { date in
                        logCall(date: date)
                    }
                }
            }
        }
    }

    private var dateChoiceTitle: String {
        guard let person = selectedPerson else { return "" }
        return "Log a call with \(person.name)"
    }

    private func logCall(date: Date) {
        guard let person = selectedPerson else { return }
        person.lastContactedAt = date
        notificationService.reschedule(for: person)
        selectedPerson = nil
        dismiss()
    }
}
