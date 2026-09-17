import SwiftUI
import SwiftData

struct PostCallPromptView: View {
    @Environment(NotificationService.self) private var notificationService
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
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedPeople) { person in
                        Button {
                            log(person)
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
            .navigationTitle("Just hung up — who was that?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not on my list") { dismiss() }
                }
            }
        }
    }

    private func log(_ person: Person) {
        person.lastContactedAt = Date()
        notificationService.reschedule(for: person)
        dismiss()
    }
}
