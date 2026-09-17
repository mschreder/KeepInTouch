import SwiftUI
import SwiftData

@main
struct KeepInTouchApp: App {
    @State private var notificationService = NotificationService()
    @State private var callObserverService = CallObserverService()
    @State private var showPostCallPrompt = false

    var body: some Scene {
        WindowGroup {
            PeopleListView()
                .environment(notificationService)
                .sheet(isPresented: $showPostCallPrompt) {
                    PostCallPromptView()
                }
                .onAppear {
                    callObserverService.onCallEnded = {
                        showPostCallPrompt = true
                    }
                    Task {
                        await notificationService.requestAuthorization()
                    }
                }
        }
        .modelContainer(for: Person.self)
    }
}
