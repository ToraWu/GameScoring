import SwiftUI

/// Home tab — resume banner, featured game, and the recent games strip.
/// M1: placeholder. Real content lands in M6.
struct HomeView: View {
  var body: some View {
    NavigationStack {
      PlaceholderView(
        systemImage: "house",
        title: "Home",
        subtitle: "Your featured game and recent plays will appear here."
      )
      .navigationTitle("BoardScore")
      .background(Theme.background)
    }
  }
}

#Preview {
  HomeView()
}
