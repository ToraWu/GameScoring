import Foundation

/// Pure helpers over completed sessions: play counts, the most-played game
/// (Home's featured card), and the History search filter.
enum HistoryStats {
  /// Number of completed sessions per `gameID`.
  static func playCounts(_ sessions: [GameSession]) -> [String: Int] {
    var counts: [String: Int] = [:]
    for session in sessions where !session.isInProgress {
      counts[session.gameID, default: 0] += 1
    }
    return counts
  }

  /// The most-played game ID; ties broken by game ID for determinism.
  static func mostPlayedGameID(_ sessions: [GameSession]) -> String? {
    playCounts(sessions)
      .max { lhs, rhs in lhs.value != rhs.value ? lhs.value < rhs.value : lhs.key > rhs.key }?
      .key
  }

  /// True if the session matches a History search query. An empty query matches
  /// everything; otherwise the game name or any player name must contain it.
  static func matches(_ session: GameSession, query: String) -> Bool {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return true }

    if session.gameName.localizedCaseInsensitiveContains(trimmed) { return true }
    return session.playerScores.contains { score in
      score.player?.name.localizedCaseInsensitiveContains(trimmed) ?? false
    }
  }
}
