import SwiftData
import SwiftUI

/// Score-entry screen for an in-progress session.
/// M3: placeholder confirming the session was created and the players carried
/// through. The real category inputs and running totals land in M4.
struct ScoringView: View {
  let session: GameSession

  var body: some View {
    PlaceholderView(
      systemImage: "square.and.pencil",
      title: "Scoring",
      subtitle: "\(session.gameName) · \(session.playerScores.count) players.\n"
        + "Score entry arrives in M4."
    )
    .navigationTitle(session.gameName)
    .navigationBarTitleDisplayMode(.inline)
    .background(Theme.background)
  }
}
