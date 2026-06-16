import SwiftUI

/// Warm Table design tokens. Single source of truth for colors so screens never
/// hardcode hex values. See PRD §Visual Style.
enum Theme {
  // Surfaces
  static let background = Color(hex: 0xfaf5ed)        // warm cream
  static let iconBackground = Color(hex: 0xf7ece0)    // warm frosted glass

  // Accents
  static let accentPrimary = Color(hex: 0xb45309)     // amber
  static let accentSecondary = Color(hex: 0xd97706)   // gold
  static let accentDeep = Color(hex: 0x92400e)        // mahogany

  // Text
  static let textPrimary = Color(hex: 0x1c1008)
  static let textSecondary = Color(red: 50 / 255, green: 20 / 255, blue: 0, opacity: 0.65)

  /// Distinct colour for negative scores (e.g. military defeats, failed tickets).
  static let negative = Color(hex: 0xdc2626)

  /// Eight avatar swatches, in selection order. See PRD §Avatar colour palette.
  static let avatarPalette: [String] = [
    "#e11d48", "#ea580c", "#ca8a04", "#16a34a",
    "#0891b2", "#4f46e5", "#7c3aed", "#db2777",
  ]
}

extension Color {
  /// Builds a color from a 24-bit RGB integer literal, e.g. `Color(hex: 0xb45309)`.
  init(hex: UInt32, opacity: Double = 1) {
    let r = Double((hex >> 16) & 0xff) / 255
    let g = Double((hex >> 8) & 0xff) / 255
    let b = Double(hex & 0xff) / 255
    self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
  }

  /// Builds a color from a `#rrggbb` string, falling back to gray on bad input.
  /// Used for `Player.avatarColor` values stored as hex strings.
  init(hexString: String) {
    let trimmed = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    if let value = UInt32(trimmed, radix: 16), trimmed.count == 6 {
      self.init(hex: value)
    } else {
      self = .gray
    }
  }
}
