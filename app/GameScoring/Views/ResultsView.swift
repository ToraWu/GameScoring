import SwiftData
import SwiftUI

/// Final standings for a completed session: a winner header, then each player
/// ranked (competition ranking — ties share a rank) with their category
/// breakdown. The session is already marked complete by `SessionService.finish`.
struct ResultsView: View {
  let session: GameSession

  @Environment(\.dismissFlow) private var dismissFlow

  private var game: (any ScoringGame)? { GameRegistry.game(for: session.gameID) }

  /// Scores ordered for display: best rank first, then higher total, then name.
  private var rankedScores: [PlayerScore] {
    session.playerScores.sorted { lhs, rhs in
      if lhs.rank != rhs.rank { return lhs.rank < rhs.rank }
      if lhs.totalScore != rhs.totalScore { return lhs.totalScore > rhs.totalScore }
      return (lhs.player?.name ?? "") < (rhs.player?.name ?? "")
    }
  }

  private var winnerNames: [String] {
    rankedScores
      .filter { score in score.player.map { session.winnerIDs.contains($0.id) } ?? false }
      .compactMap { $0.player?.name }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        winnerHeader
        VStack(spacing: 12) {
          ForEach(rankedScores) { score in
            ResultRow(score: score, game: game, isWinner: isWinner(score))
          }
        }
      }
      .padding(20)
    }
    .background(Theme.background)
    .navigationTitle("Results")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Done") { dismissFlow() }
          .fontWeight(.semibold)
      }
    }
  }

  private var winnerHeader: some View {
    VStack(spacing: 10) {
      Image(systemName: "crown.fill")
        .font(.system(size: 44))
        .foregroundStyle(Theme.accentSecondary)
        .symbolEffect(.bounce, options: .nonRepeating)

      if session.isTie {
        Text("It's a tie!")
          .font(.title2.bold())
          .foregroundStyle(Theme.textPrimary)
        Text(winnerNames.joined(separator: " & "))
          .font(.headline)
          .foregroundStyle(Theme.textSecondary)
      } else {
        Text("\(winnerNames.first ?? "—") wins!")
          .font(.title2.bold())
          .foregroundStyle(Theme.textPrimary)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .background(.regularMaterial, in: .rect(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .strokeBorder(.white.opacity(0.5), lineWidth: 1)
    )
  }

  private func isWinner(_ score: PlayerScore) -> Bool {
    score.player.map { session.winnerIDs.contains($0.id) } ?? false
  }
}

/// One ranked player: rank badge, avatar, name (+ crown), total, and a compact
/// category breakdown.
private struct ResultRow: View {
  let score: PlayerScore
  let game: (any ScoringGame)?
  let isWinner: Bool

  private var breakdown: [(name: String, value: Double)] {
    guard let game else { return [] }
    let scores = score.categoryScores
    return game.categories
      .filter { scores[$0.id] != nil }
      .sorted { $0.displayOrder < $1.displayOrder }
      .map { ($0.name, scores[$0.id] ?? 0) }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        RankBadge(rank: score.rank)
        PlayerAvatar(
          name: score.player?.name ?? "?",
          colorHex: score.player?.avatarColor ?? "#888888",
          size: 40
        )
        Text(score.player?.name ?? "Player")
          .font(.headline)
          .foregroundStyle(Theme.textPrimary)
        if isWinner {
          Image(systemName: "crown.fill")
            .font(.subheadline)
            .foregroundStyle(Theme.accentSecondary)
        }
        Spacer()
        Text("\(Int(score.totalScore.rounded()))")
          .font(.title3.bold().monospacedDigit())
          .foregroundStyle(Theme.accentPrimary)
        Text("VP")
          .font(.caption)
          .foregroundStyle(Theme.textSecondary)
      }

      if !breakdown.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(breakdown, id: \.name) { item in
              VStack(spacing: 1) {
                Text("\(Int(item.value.rounded()))")
                  .font(.subheadline.weight(.semibold).monospacedDigit())
                  .foregroundStyle(Theme.textPrimary)
                Text(item.name)
                  .font(.caption2)
                  .foregroundStyle(Theme.textSecondary)
              }
              .frame(minWidth: 52)
              .padding(.vertical, 6)
              .padding(.horizontal, 8)
              .background(Theme.background, in: .rect(cornerRadius: 10))
            }
          }
        }
      }
    }
    .padding(14)
    .background(.regularMaterial, in: .rect(cornerRadius: 18))
    .overlay(
      RoundedRectangle(cornerRadius: 18)
        .strokeBorder(isWinner ? Theme.accentSecondary.opacity(0.6) : .white.opacity(0.4),
                      lineWidth: isWinner ? 2 : 1)
    )
  }
}

/// Circular rank indicator; the top three get a warm accent tint.
private struct RankBadge: View {
  let rank: Int

  private var tint: Color {
    switch rank {
    case 1: return Theme.accentSecondary
    case 2: return Theme.textSecondary
    case 3: return Theme.accentDeep
    default: return Theme.textSecondary.opacity(0.5)
    }
  }

  var body: some View {
    Text("\(rank)")
      .font(.subheadline.bold().monospacedDigit())
      .foregroundStyle(.white)
      .frame(width: 28, height: 28)
      .background(tint, in: .circle)
  }
}
