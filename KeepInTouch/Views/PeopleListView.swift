import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService
    @Query(sort: \Person.createdAt) private var people: [Person]
    @State private var showingAddPerson = false

    private var sortedPeople: [Person] {
        OverdueCalculator.sorted(people)
    }

    private var overduePeople: [Person] {
        sortedPeople.filter { OverdueCalculator.status(for: $0) == .overdue }
    }

    private var dueSoonPeople: [Person] {
        sortedPeople.filter { OverdueCalculator.status(for: $0) == .dueSoon }
    }

    private var onTrackPeople: [Person] {
        sortedPeople.filter { OverdueCalculator.status(for: $0) == .onTrack }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                if people.isEmpty {
                    ContentUnavailableView {
                        Label("No one yet", systemImage: "leaf.fill")
                    } description: {
                        Text("Add friends and family to start tracking how often you talk.")
                    }
                    .foregroundStyle(Theme.ink)
                    .tint(Theme.inkMuted)
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        section("Overdue", overduePeople)
                        section("Due Soon", dueSoonPeople)
                        section("On Track", onTrackPeople)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.background)
            .navigationTitle("Keep In Touch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPerson = true
                    } label: {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerson) {
                AddPersonView()
            }
            .task {
                // Wait for the authorization prompt to resolve before scheduling,
                // otherwise reminders can be added while still unauthorized.
                await notificationService.requestAuthorization()
                notificationService.rescheduleAll(for: people)
            }
        }
    }

    private var header: some View {
        Text("Keep In Touch")
            .font(.organic(.largeTitle))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Theme.background)
    }

    @ViewBuilder
    private func section(_ title: String, _ list: [Person]) -> some View {
        if !list.isEmpty {
            Section(title) {
                ForEach(list) { person in
                    NavigationLink {
                        PersonDetailView(person: person)
                    } label: {
                        PersonRowView(person: person)
                    }
                    .listRowBackground(Theme.surface)
                }
                .onDelete { offsets in
                    delete(list, at: offsets)
                }
            }
        }
    }

    private func delete(_ list: [Person], at offsets: IndexSet) {
        for index in offsets {
            let person = list[index]
            notificationService.cancelReminder(for: person)
            modelContext.delete(person)
        }
    }
}
