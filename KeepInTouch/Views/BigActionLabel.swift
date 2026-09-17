import SwiftUI

/// A large, flat, custom-styled action surface used in place of default
/// system buttons and action sheets throughout the log-a-call flow.
struct BigActionLabel: View {
    let title: String
    var systemImage: String? = nil
    var background: Color
    var foreground: Color = .white
    var bordered: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 17, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(background)
        .foregroundStyle(foreground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            if bordered {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.divider, lineWidth: 1.5)
            }
        }
    }
}
