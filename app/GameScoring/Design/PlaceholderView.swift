import SwiftUI

/// Temporary centered placeholder used by tabs whose real content lands in a
/// later milestone. Replaced screen-by-screen; not part of the shipping UI.
struct PlaceholderView: View {
  let systemImage: String
  let title: String
  let subtitle: String

  var body: some View {
    ContentUnavailableView {
      Label(title, systemImage: systemImage)
        .foregroundStyle(Theme.textPrimary)
    } description: {
      Text(subtitle)
        .foregroundStyle(Theme.textSecondary)
    }
    .symbolRenderingMode(.hierarchical)
    .tint(Theme.accentPrimary)
  }
}
