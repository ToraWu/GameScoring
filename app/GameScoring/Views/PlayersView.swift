import SwiftUI

/// Players tab — the roster of reusable player profiles.
/// M1: placeholder. Real CRUD lands in M2.
struct PlayersView: View {
  var body: some View {
    NavigationStack {
      PlaceholderView(
        systemImage: "person.2",
        title: "Players",
        subtitle: "Add players to your roster to use them across games."
      )
      .navigationTitle("Players")
      .background(Theme.background)
    }
  }
}

#Preview {
  PlayersView()
}
