import SwiftUI
import UIKit

/// A warm, organic palette (cream, terracotta, sage) used throughout the app,
/// adaptive for light/dark via UIKit's dynamic color provider.
enum Theme {
    private static func adaptive(light: (UInt8, UInt8, UInt8), dark: (UInt8, UInt8, UInt8)) -> Color {
        Color(UIColor { trait in
            let (r, g, b) = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
        })
    }

    static let background = adaptive(light: (0xF3, 0xEC, 0xDF), dark: (0x1B, 0x17, 0x12))
    static let surface = adaptive(light: (0xFB, 0xF6, 0xEC), dark: (0x24, 0x1F, 0x18))
    static let ink = adaptive(light: (0x2B, 0x21, 0x18), dark: (0xF1, 0xE7, 0xD6))
    static let inkMuted = adaptive(light: (0x8A, 0x78, 0x63), dark: (0xA9, 0x9A, 0x85))
    static let divider = adaptive(light: (0xE4, 0xD9, 0xC5), dark: (0x3A, 0x33, 0x2A))

    static let overdue = adaptive(light: (0x9C, 0x3F, 0x2E), dark: (0xD9, 0x7A, 0x64))
    static let dueSoon = adaptive(light: (0xB0, 0x8A, 0x3E), dark: (0xD9, 0xB8, 0x76))
    static let onTrack = adaptive(light: (0x5B, 0x7A, 0x5C), dark: (0x8F, 0xB0, 0x90))
    static let logCallGreen = adaptive(light: (0x33, 0x4D, 0x37), dark: (0x5C, 0x87, 0x63))

    static func statusColor(_ status: ContactStatus) -> Color {
        switch status {
        case .overdue: return overdue
        case .dueSoon: return dueSoon
        case .onTrack: return onTrack
        }
    }
}

extension Font {
    /// The app's warm, editorial display type — New York (iOS's built-in serif), used
    /// sparingly for names and titles the way a hand-addressed card feels more personal
    /// than a printed label.
    static func organic(_ style: Font.TextStyle, weight: Font.Weight = .semibold) -> Font {
        .system(style, design: .serif).weight(weight)
    }
}
