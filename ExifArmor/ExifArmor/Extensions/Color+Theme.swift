import SwiftUI

/// Fallback color definitions that match the asset catalog.
/// Use `Color("AccentCyan")` in views — these are only needed if
/// the asset catalog isn't configured yet.
extension Color {
    static let armorCyan = Color(red: 0.0, green: 0.94, blue: 1.0)
    static let armorMagenta = Color(red: 1.0, green: 0.0, blue: 0.43)
    static let armorGold = Color(red: 1.0, green: 0.82, blue: 0.2)
    static let armorGreen = Color(red: 0.2, green: 0.9, blue: 0.5)
    static let armorRed = Color(red: 1.0, green: 0.25, blue: 0.25)
    static let armorBgDark = Color(red: 0.035, green: 0.035, blue: 0.055)
    static let armorCardBg = Color(red: 0.08, green: 0.08, blue: 0.11)
    static let armorTextPrimary = Color(red: 0.92, green: 0.94, blue: 0.97)
    static let armorTextSecondary = Color(red: 0.55, green: 0.58, blue: 0.65)
}

/// Asset catalog color names — reference list for the team.
///
/// These should exist in Assets.xcassets as Color Sets:
/// - AccentCyan       #00F0FF
/// - AccentMagenta    #FF006E
/// - AccentGold       #FFD233
/// - SuccessGreen     #33E680
/// - WarningRed       #FF4040
/// - BackgroundDark   #090910
/// - CardBackground   #14141C
/// - TextPrimary      #EBF0F7
/// - TextSecondary    #8C94A6
