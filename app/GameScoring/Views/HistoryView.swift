import SwiftData
import SwiftUI

/// History tab — completed sessions, newest first, filterable by game or
/// player. Tapping a row opens its final standings.
struct HistoryView: View {
  @Query(
    filter: #Predicate<GameSession> { $0.completedAt != nil },
    sort: \GameSession.createdAt,
    order: .reverse
  )
  private var sessions: [GameSession]

  @State private var query = ""

  private var filtered: [GameSession] {
    sessions.filter { HistoryStats.matches($0, query: query) }
  }

  var body: some View {
    NavigationStack {
      Group {
        if sessions.isEmpty {
          PlaceholderView(
            systemImage: "clock.arrow.circlepath",
            title: "No Games Yet",
            subtitle: "Finished games will be listed here, newest first."
          )
        } else if filtered.isEmpty {
          ContentUnavailableView.search(text: query)
        } else {
          List {
            ForEach(filtered) { session in
              NavigationLink(value: session) {
                HistorySessionRow(session: session)
              }
              .listRowBackground(Color.clear)
            }
          }
          .scrollContentBackground(.hidden)
        }
      }
      .background(Theme.background)
      .navigationTitle("History")
      .searchable(text: $query, prompt: "Game or player")
      .navigationDestination(for: GameSession.self) { session in
        StandingsView(session: session)
          .navigationTitle(session.createdAt.formatted(date: .abbreviated, time: .omitted))
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}

/// One History list row: game, date, player avatars, and the winner.
private struct HistorySessionRow: View {
  let session: GameSession

  private var winnerNames: String {
    let names = session.playerScores
      .filter { score in score.player.map { session.winnerIDs.contains($0.id) } ?? false }
      .compactMap { $0.player?.name }
    return names.joined(separator: " & ")
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(session.gameName)
          .font(.headline)
          .foregroundStyle(Theme.textPrimary)
        Spacer()
        Text(session.createdAt.formatted(date: .abbreviated, time: .omitted))
          .font(.caption)
          .foregroundStyle(Theme.textSecondary)
      }

      HStack(spacing: -8) {
        ForEach(session.playerScores.prefix(6)) { score in
          PlayerAvatar(
            name: score.player?.name ?? "?",
            colorHex: score.player?.avatarColor ?? "#888888",
            size: 28
          )
        }
        Spacer()
        if !winnerNames.isEmpty {
          Label(winnerNames, systemImage: "crown.fill")
            .font(.caption.weight(.medium))
            .foregroundStyle(Theme.accentSecondary)
            .labelStyle(.titleAndIcon)
        }
      }
    }
    .padding(.vertical, 6)
  }
}
