import SwiftUI

/// A small "pick a past date" sheet used whenever logging a call that
/// happened before today, rather than right now.
struct LogCallDatePickerSheet: View {
    @State private var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    let onSave: (Date) -> Void

    init(initialDate: Date, onSave: @escaping (Date) -> Void) {
        _selectedDate = State(initialValue: min(initialDate, Date()))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Call date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                Spacer()
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Log a Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(selectedDate)
                        dismiss()
                    }
                }
            }
        }
    }
}
