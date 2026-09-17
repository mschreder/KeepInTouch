import SwiftUI
import UIKit

struct PersonRowView: View {
    let person: Person

    var body: some View {
        HStack(spacing: 12) {
            avatar
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.organic(.headline))
                    .foregroundStyle(Theme.ink)
                Text(lastContactedText)
                    .font(.subheadline)
                    .foregroundStyle(Theme.inkMuted)
            }
            Spacer()
            statusBadge
        }
        .padding(.vertical, 4)
    }

    private var avatar: some View {
        Group {
            if let data = person.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .scaledToFill()
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .overlay(Circle().stroke(Theme.divider, lineWidth: 1.5))
    }

    private var lastContactedText: String {
        guard let last = person.lastContactedAt else { return "Never called" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Last called \(formatter.localizedString(for: last, relativeTo: Date()))"
    }

    private var statusBadge: some View {
        let status = OverdueCalculator.status(for: person)
        return Text(label(for: status))
            .font(.caption).bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Theme.statusColor(status).opacity(0.16))
            .foregroundStyle(Theme.statusColor(status))
            .clipShape(Capsule())
    }

    private func label(for status: ContactStatus) -> String {
        switch status {
        case .overdue: return "Overdue"
        case .dueSoon: return "Due Soon"
        case .onTrack: return "On Track"
        }
    }
}
