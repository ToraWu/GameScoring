import SwiftUI

/// A row of selectable avatar color swatches drawn from `Theme.avatarPalette`.
struct AvatarColorPicker: View {
  @Binding var selection: String

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

  var body: some View {
    LazyVGrid(columns: columns, spacing: 12) {
      ForEach(Theme.avatarPalette, id: \.self) { hex in
        Circle()
          .fill(Color(hexString: hex))
          .frame(height: 44)
          .overlay {
            if hex == selection {
              Circle().strokeBorder(Theme.textPrimary, lineWidth: 3)
            }
          }
          .onTapGesture { selection = hex }
          .accessibilityLabel(hex)
          .accessibilityAddTraits(hex == selection ? [.isButton, .isSelected] : .isButton)
      }
    }
  }
}

#Preview {
  AvatarColorPicker(selection: .constant(Theme.avatarPalette[2]))
    .padding()
}
