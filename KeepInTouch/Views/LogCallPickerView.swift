import SwiftUI
import SwiftData

/// The general "log a call" flow from the main screen: pick who you called,
/// then a custom screen for whether it was today or another day.
struct LogCallPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var people: [Person]
    @State private var searchText = ""
    @State private var showingAddPerson = false

    private var sortedPeople: [Person] {
        OverdueCalculator.sorted(people)
    }

    private var filteredPeople: [Person] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return sortedPeople }
        return sortedPeople.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }

    var body: some View {
        NavigationStack {
            List {
                if people.isEmpty {
                    Text("Add people first to log calls.")
                        .foregroundStyle(Theme.inkMuted)
                } else if filteredPeople.isEmpty {
                    Text("No one matches \u{201C}\(searchText)\u{201D}.")
                        .foregroundStyle(Theme.inkMuted)
                } else {
                    ForEach(filteredPeople) { person in
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
            .searchable(text: $searchText, prompt: "Search people")
            .navigationTitle("Who did you call?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPerson = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerson) {
                AddPersonView()
            }
        }
    }
}
