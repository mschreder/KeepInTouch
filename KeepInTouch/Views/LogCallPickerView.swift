import SwiftUI
import SwiftData

/// The general "log a call" flow from the main screen: pick who you called,
/// then a custom screen for whether it was today or another day.
struct LogCallPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var people: [Person]

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
                        NavigationLink {
                            LogCallDateChoiceView(person: person, onLogged: { dismiss() })
                        } label: {
                            PersonRowView(person: person)
                        }
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
        }
    }
}
