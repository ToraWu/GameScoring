import SwiftData
import SwiftUI

/// A player's profile and play record: headline stats, a per-game breakdown,
/// and their recent games. Reached by tapping a player's avatar in the roster.
struct PlayerDetailView: View {
  let player: Player

  @Query(
    filter: #Predicate<GameSession> { $0.completedAt != nil },
    sort: \GameSession.createdAt,
    order: .reverse
  )
  private var sessions: [GameSession]

  private var summary: PlayerStats.Summary {
    PlayerStats.summary(for: player.id, in: sessions)
  }

  private var recentGames: [GameSession] {
    sessions.filter { session in
      session.playerScores.contains { $0.player?.id == player.id }
    }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        profile
        statCards
        colorSection
        if !summary.byGame.isEmpty {
          breakdownSection
        }
        if !recentGames.isEmpty {
          recentSection
        }
      }
      .padding(20)
    }
    .background(Theme.background)
    .navigationTitle(player.name)
    .navigationBarTitleDisplayMode(.inline)
  }

  private var profile: some View {
    VStack(spacing: 10) {
      PlayerAvatar(name: player.name, colorHex: player.avatarColor, size: 72)
      Text(player.name)
        .font(.title2.bold())
        .foregroundStyle(Theme.textPrimary)
    }
  }

  private var statCards: some View {
    HStack(spacing: 12) {
      statCard("Games", "\(summary.gamesPlayed)")
      statCard("Wins", "\(summary.wins)")
      statCard("Win rate", "\(Int((summary.winRate * 100).rounded()))%")
    }
  }

  private var colorSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Colour")
        .font(.headline)
        .foregroundStyle(Theme.textPrimary)
      AvatarColorPicker(selection: Binding(
        get: { player.avatarColor },
        set: { player.setAvatarColor($0) }
      ))
      .padding(14)
      .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
  }

  private func statCard(_ label: String, _ value: String) -> some View {
    VStack(spacing: 4) {
      Text(value)
        .font(.title.bold().monospacedDigit())
        .foregroundStyle(Theme.accentPrimary)
      Text(label)
        .font(.caption)
        .foregroundStyle(Theme.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(.regularMaterial, in: .rect(cornerRadius: 16))
  }

  private var breakdownSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("By game")
        .font(.headline)
        .foregroundStyle(Theme.textPrimary)
      VStack(spacing: 0) {
        ForEach(summary.byGame) { game in
          HStack {
            Text(game.gameName)
              .foregroundStyle(Theme.textPrimary)
            Spacer()
            Text("\(game.wins) / \(game.played) won")
              .font(.subheadline.monospacedDigit())
              .foregroundStyle(Theme.textSecondary)
          }
          .padding(.vertical, 12)
          if game.id != summary.byGame.last?.id {
            Divider().overlay(Theme.textSecondary.opacity(0.15))
          }
        }
      }
      .padding(.horizontal, 14)
      .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
  }

  private var recentSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Recent games")
        .font(.headline)
        .foregroundStyle(Theme.textPrimary)
      VStack(spacing: 0) {
        ForEach(recentGames.prefix(10)) { session in
          NavigationLink(value: session) {
            HStack {
              VStack(alignment: .leading, spacing: 2) {
                Text(session.gameName)
                  .foregroundStyle(Theme.textPrimary)
                Text(session.createdAt.formatted(date: .abbreviated, time: .omitted))
                  .font(.caption)
                  .foregroundStyle(Theme.textSecondary)
              }
              Spacer()
              if session.winnerIDs.contains(player.id) {
                Label("Won", systemImage: "crown.fill")
                  .font(.caption.weight(.medium))
                  .foregroundStyle(Theme.accentSecondary)
                  .labelStyle(.titleAndIcon)
              }
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            }
            .padding(.vertical, 12)
          }
          .buttonStyle(.plain)
          if session.id != recentGames.prefix(10).last?.id {
            Divider().overlay(Theme.textSecondary.opacity(0.15))
          }
        }
      }
      .padding(.horizontal, 14)
      .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
  }
}
