import SwiftUI

/// A custom "pick a past date" screen with our own confirm button in place
/// of a system sheet's toolbar Cancel/Save.
struct LogCallCustomDateView: View {
    let person: Person
    var onLogged: () -> Void

    @Environment(NotificationService.self) private var notificationService
    @State private var selectedDate: Date

    init(person: Person, onLogged: @escaping () -> Void) {
        self.person = person
        self.onLogged = onLogged
        _selectedDate = State(initialValue: min(person.lastContactedAt ?? Date(), Date()))
    }

    var body: some View {
        VStack(spacing: 20) {
            DatePicker(
                "Call date",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal, 12)
            .padding(.top, 16)

            Spacer()

            Button {
                logCall(date: selectedDate)
            } label: {
                BigActionLabel(title: "Confirm", systemImage: "checkmark", background: Theme.onTrack)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Theme.background)
        .navigationTitle("Select a Date")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func logCall(date: Date) {
        person.lastContactedAt = date
        notificationService.reschedule(for: person)
        onLogged()
    }
}
