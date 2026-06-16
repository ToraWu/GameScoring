import SwiftData
import SwiftUI

/// Final standings shown at the end of the score-entry flow. The session is
/// already marked complete by `SessionService.finish`.
/// - **Edit** pops back to Score Entry to revise (re-Finish re-ranks the session).
/// - **Play again** opens Setup with the same game + players.
/// - **Done** dismisses the whole flow.
struct ResultsView: View {
  let session: GameSession

  @Environment(\.dismiss) private var dismiss
  @Environment(\.dismissFlow) private var dismissFlow

  @State private var replay: GameRef?

  private var samePlayerIDs: [UUID] {
    session.playerScores
      .sorted { ($0.player?.createdAt ?? .distantPast) < ($1.player?.createdAt ?? .distantPast) }
      .compactMap { $0.player?.id }
  }

  var body: some View {
    StandingsView(session: session)
      .safeAreaInset(edge: .bottom) { playAgainBar }
      .navigationTitle("Results")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Edit") { dismiss() }  // back to Score Entry; inputs are retained
            .accessibilityIdentifier("results.edit")
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismissFlow() }
            .fontWeight(.semibold)
            .accessibilityIdentifier("results.done")
        }
      }
      .navigationDestination(item: $replay) { ref in
        GameSetupView(game: ref.game, initialPlayerIDs: samePlayerIDs)
      }
  }

  @ViewBuilder
  private var playAgainBar: some View {
    if let game = GameRegistry.game(for: session.gameID) {
      Button {
        replay = GameRef(game: game)
      } label: {
        Label("Play again", systemImage: "arrow.counterclockwise")
          .font(.headline)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
      }
      .buttonStyle(.borderedProminent)
      .tint(Theme.accentPrimary)
      .padding(.horizontal, 20)
      .padding(.bottom, 8)
      .accessibilityIdentifier("results.playAgain")
    }
  }
}
