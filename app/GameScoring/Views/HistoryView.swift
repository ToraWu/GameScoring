import SwiftUI

/// History tab — completed sessions sorted by date, filterable by game or player.
/// M1: placeholder. Real content lands in M6.
struct HistoryView: View {
  var body: some View {
    NavigationStack {
      PlaceholderView(
        systemImage: "clock.arrow.circlepath",
        title: "History",
        subtitle: "Completed games will be listed here, newest first."
      )
      .navigationTitle("History")
      .background(Theme.background)
    }
  }
}

#Preview {
  HistoryView()
}
