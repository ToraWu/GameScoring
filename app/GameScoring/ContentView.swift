import SwiftUI

/// Root navigation shell: a four-tab Liquid Glass tab bar. On iOS 26 the
/// floating glass treatment and specular rim are applied by the system to the
/// `TabView`'s bottom bar automatically — no custom bar drawing needed.
struct ContentView: View {
  var body: some View {
    TabView {
      Tab("Home", systemImage: "house") {
        HomeView()
      }
      Tab("Players", systemImage: "person.2") {
        PlayersView()
      }
      Tab("History", systemImage: "clock.arrow.circlepath") {
        HistoryView()
      }
      Tab("Shelf", systemImage: "square.grid.2x2") {
        ShelfView()
      }
    }
    .tint(Theme.accentPrimary)
  }
}

#Preview {
  ContentView()
    .modelContainer(.preview)
}
