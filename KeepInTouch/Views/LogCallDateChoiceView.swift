import SwiftUI
import UIKit

/// A custom screen — not a system action sheet — asking whether a logged
/// call happened today or on some other day.
struct LogCallDateChoiceView: View {
    let person: Person
    var onLogged: () -> Void

    @Environment(NotificationService.self) private var notificationService

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                avatar
                Text(person.name)
                    .font(.organic(.title2))
                    .foregroundStyle(Theme.ink)
                Text("When did you call?")
                    .foregroundStyle(Theme.inkMuted)
            }
            .padding(.top, 32)

            Spacer()

            VStack(spacing: 14) {
                Button {
                    logCall(date: Date())
                } label: {
                    BigActionLabel(title: "Today", systemImage: "checkmark.circle.fill", background: Theme.onTrack)
                }
                .buttonStyle(.plain)

                NavigationLink {
                    LogCallCustomDateView(person: person, onLogged: onLogged)
                } label: {
                    BigActionLabel(
                        title: "Select Other Date",
                        systemImage: "calendar",
                        background: Theme.surface,
                        foreground: Theme.ink,
                        bordered: true
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxHeight: .infinity)
        .background(Theme.background)
        .navigationTitle("Log a Call")
        .navigationBarTitleDisplayMode(.inline)
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
        .frame(width: 72, height: 72)
        .clipShape(Circle())
        .overlay(Circle().stroke(Theme.divider, lineWidth: 1.5))
    }

    private func logCall(date: Date) {
        person.lastContactedAt = date
        notificationService.reschedule(for: person)
        onLogged()
    }
}
