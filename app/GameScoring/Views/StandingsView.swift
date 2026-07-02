import SwiftData
import SwiftUI

/// Reusable ranked standings for a completed session — a winner header plus a
/// ranked card per player with their category breakdown. Used by both the
/// post-game Results screen and the History detail screen.
struct StandingsView: View {
  let session: GameSession
  /// When true, the winner reveal plays a confetti + entrance celebration.
  /// Set on the post-game Results screen; left off for History detail.
  var celebrate: Bool = false

  @State private var revealed = false
  @State private var showConfetti = false

  private var game: (any ScoringGame)? { GameRegistry.game(for: session.gameID) }

  /// Best rank first, then higher total, then name.
  private var rankedScores: [PlayerScore] {
    session.playerScores.sorted { lhs, rhs in
      if lhs.rank != rhs.rank { return lhs.rank < rhs.rank }
      if lhs.totalScore != rhs.totalScore { return lhs.totalScore > rhs.totalScore }
      return (lhs.player?.name ?? "") < (rhs.player?.name ?? "")
    }
  }

  private var winners: [PlayerScore] { rankedScores.filter(isWinner) }
  private var winnerNames: [String] { winners.compactMap { $0.player?.name } }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        winnerHero
        VStack(spacing: 12) {
          ForEach(rankedScores) { score in
            ResultRow(score: score, game: game, isWinner: isWinner(score))
          }
        }
      }
      .padding(20)
    }
    .background(Theme.background)
    .overlay {
      if showConfetti { ConfettiView() }
    }
    .onAppear(perform: startReveal)
  }

  // MARK: - Winner hero

  private var winnerHero: some View {
    let avatarSize: CGFloat = winners.count <= 1 ? 104 : (winners.count <= 3 ? 78 : 56)

    return VStack(spacing: 14) {
      Image(systemName: "crown.fill")
        .font(.system(size: 54))
        .foregroundStyle(Theme.accentSecondary)
        .symbolEffect(.bounce, options: .nonRepeating, value: revealed)

      Text(session.isTie ? "It's a tie!" : "\(winnerNames.first ?? "—") wins!")
        .font(.largeTitle.bold())
        .foregroundStyle(Theme.textPrimary)
        .multilineTextAlignment(.center)

      HStack(alignment: .top, spacing: 16) {
        ForEach(winners) { score in
          VStack(spacing: 6) {
            PlayerAvatar(
              name: score.player?.name ?? "?",
              colorHex: score.player?.avatarColor ?? "#888888",
              size: avatarSize
            )
            .overlay(Circle().strokeBorder(Theme.accentSecondary, lineWidth: 3))
            .shadow(color: Theme.accentSecondary.opacity(0.55), radius: 14)

            Text(score.player?.name ?? "Player")
              .font(.title3.bold())
              .foregroundStyle(Theme.textPrimary)
            Text("\(Int(score.totalScore.rounded())) VP")
              .font(.title2.bold().monospacedDigit())
              .foregroundStyle(Theme.accentPrimary)
          }
        }
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 28)
    .background(.regularMaterial, in: .rect(cornerRadius: 28))
    .overlay(
      RoundedRectangle(cornerRadius: 28)
        .strokeBorder(Theme.accentSecondary.opacity(0.5), lineWidth: 1.5)
    )
    .scaleEffect(hidden ? 0.85 : 1)
    .opacity(hidden ? 0 : 1)
  }

  /// True only during the pre-reveal frame of a celebration.
  private var hidden: Bool { celebrate && !revealed }

  private func startReveal() {
    guard celebrate else { revealed = true; return }
    guard !revealed else { return }
    showConfetti = true
    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { revealed = true }
    #if canImport(UIKit)
    UINotificationFeedbackGenerator().notificationOccurred(.success)
    #endif
    // Unmount the confetti once the burst has played out.
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) { showConfetti = false }
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

  private var breakdown: [(name: String, value: Double, icon: String, colorHex: String)] {
    guard let game else { return [] }
    let scores = score.categoryScores
    return game.categories
      .filter { scores[$0.id] != nil }
      .sorted { $0.displayOrder < $1.displayOrder }
      .map { ($0.name, scores[$0.id] ?? 0, $0.icon, $0.colorHex) }
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
              VStack(spacing: 2) {
                Image(systemName: item.icon)
                  .font(.caption)
                  .foregroundStyle(Color(hexString: item.colorHex))
                Text("\(Int(item.value.rounded()))")
                  .font(.subheadline.weight(.semibold).monospacedDigit())
                  .foregroundStyle(item.value < 0 ? Theme.negative : Theme.textPrimary)
                Text(item.name)
                  .font(.caption2)
                  .foregroundStyle(Theme.textSecondary)
              }
              .frame(minWidth: 54)
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
