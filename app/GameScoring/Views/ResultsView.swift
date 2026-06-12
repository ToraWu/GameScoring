import SwiftData
import SwiftUI

/// Final standings for a completed session.
/// M4: placeholder confirming the session was finalized (totals + winners).
/// The real ranked podium and tiebreaker handling land in M5.
struct ResultsView: View {
  let session: GameSession

  private var winnerNames: String {
    let names = session.playerScores
      .filter { score in score.player.map { session.winnerIDs.contains($0.id) } ?? false }
      .compactMap { $0.player?.name }
    return names.isEmpty ? "—" : names.joined(separator: ", ")
  }

  var body: some View {
    PlaceholderView(
      systemImage: "trophy",
      title: session.isTie ? "It's a tie!" : "Winner: \(winnerNames)",
      subtitle: "\(session.gameName) · final standings arrive in M5."
    )
    .navigationTitle("Results")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .background(Theme.background)
  }
}
