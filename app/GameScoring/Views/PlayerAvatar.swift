import SwiftUI

/// Circular avatar badge showing a player's first initial on their chosen color.
struct PlayerAvatar: View {
  let name: String
  let colorHex: String
  var size: CGFloat = 40

  var body: some View {
    Circle()
      .fill(Color(hexString: colorHex))
      .frame(width: size, height: size)
      .overlay {
        Text(initial)
          .font(.system(size: size * 0.44, weight: .semibold, design: .rounded))
          .foregroundStyle(.white)
      }
      .overlay {
        Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1)  // specular rim
      }
  }

  private var initial: String {
    let trimmed = name.trimmingCharacters(in: .whitespaces)
    guard let first = trimmed.first else { return "?" }
    return String(first).uppercased()
  }
}

#Preview {
  HStack(spacing: 12) {
    PlayerAvatar(name: "Ada", colorHex: "#e11d48")
    PlayerAvatar(name: "Boris", colorHex: "#0891b2")
    PlayerAvatar(name: "", colorHex: "#16a34a")
  }
  .padding()
}
