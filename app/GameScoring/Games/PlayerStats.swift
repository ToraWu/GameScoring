import Foundation

/// Aggregate play statistics for a single player, computed from completed
/// sessions. Pure and game-agnostic so it's easy to test.
enum PlayerStats {
  /// Per-game tally for a player.
  struct GameBreakdown: Identifiable {
    let gameID: String
    let gameName: String
    let played: Int
    let wins: Int
    var id: String { gameID }
    var winRate: Double { played == 0 ? 0 : Double(wins) / Double(played) }
  }

  struct Summary {
    let gamesPlayed: Int
    let wins: Int
    /// Per-game tallies, most-played first.
    let byGame: [GameBreakdown]

    var winRate: Double { gamesPlayed == 0 ? 0 : Double(wins) / Double(gamesPlayed) }
  }

  /// Summarises `playerID`'s record across the supplied sessions. In-progress
  /// sessions are ignored; a shared (tied) win counts as a win.
  static func summary(for playerID: UUID, in sessions: [GameSession]) -> Summary {
    var totalPlayed = 0
    var totalWins = 0
    var perGame: [String: (name: String, played: Int, wins: Int)] = [:]

    for session in sessions where !session.isInProgress {
      let isParticipant = session.playerScores.contains { $0.player?.id == playerID }
      guard isParticipant else { continue }

      let won = session.winnerIDs.contains(playerID)
      totalPlayed += 1
      if won { totalWins += 1 }

      var entry = perGame[session.gameID] ?? (session.gameName, 0, 0)
      entry.played += 1
      if won { entry.wins += 1 }
      perGame[session.gameID] = entry
    }

    let breakdowns = perGame
      .map { GameBreakdown(gameID: $0.key, gameName: $0.value.name,
                           played: $0.value.played, wins: $0.value.wins) }
      .sorted { $0.played != $1.played ? $0.played > $1.played : $0.gameName < $1.gameName }

    return Summary(gamesPlayed: totalPlayed, wins: totalWins, byGame: breakdowns)
  }
}
