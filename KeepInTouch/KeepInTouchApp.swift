import SwiftUI
import SwiftData

@main
struct KeepInTouchApp: App {
    @State private var notificationService = NotificationService()
    @State private var callObserverService = CallObserverService()
    @State private var showPostCallPrompt = false

    init() {
        Self.applyOrganicNavigationBarAppearance()
    }

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
                }
        }
        .modelContainer(for: Person.self)
    }

    /// Gives navigation titles the app's warm, hand-addressed feel by swapping
    /// in New York (iOS's built-in serif) in place of the default system font.
    private static func applyOrganicNavigationBarAppearance() {
        func serifFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
            let base = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            let serif = base.withDesign(.serif) ?? base
            return UIFont(descriptor: serif, size: 0)
        }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0x1B / 255, green: 0x17 / 255, blue: 0x12 / 255, alpha: 1)
                : UIColor(red: 0xF3 / 255, green: 0xEC / 255, blue: 0xDF / 255, alpha: 1)
        }
        let inkColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0xF1 / 255, green: 0xE7 / 255, blue: 0xD6 / 255, alpha: 1)
                : UIColor(red: 0x2B / 255, green: 0x21 / 255, blue: 0x18 / 255, alpha: 1)
        }
        appearance.titleTextAttributes = [.font: serifFont(forTextStyle: .headline), .foregroundColor: inkColor]
        appearance.largeTitleTextAttributes = [.font: serifFont(forTextStyle: .largeTitle), .foregroundColor: inkColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
