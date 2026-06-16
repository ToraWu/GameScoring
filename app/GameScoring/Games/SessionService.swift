import Foundation
import SwiftData

/// Domain operations for game sessions, kept out of the views so they can be
/// reused (setup, resume, results) and exercised in isolation.
enum SessionService {
  /// The single in-progress (not yet completed) session, if any.
  static func inProgress(in context: ModelContext) -> GameSession? {
    let descriptor = FetchDescriptor<GameSession>(
      predicate: #Predicate { $0.completedAt == nil }
    )
    return (try? context.fetch(descriptor))?.first
  }

  /// Starts a new game: discards any existing in-progress session (only one is
  /// kept at a time), then creates the session and a score row per player.
  /// Returns the new session.
  @discardableResult
  static func start(
    game: any ScoringGame,
    players: [Player],
    in context: ModelContext
  ) -> GameSession {
    let existing = (try? context.fetch(
      FetchDescriptor<GameSession>(predicate: #Predicate { $0.completedAt == nil })
    )) ?? []
    for session in existing {
      context.delete(session)  // cascade-deletes its PlayerScores
    }

    let session = GameSession(gameID: game.id, gameName: game.name)
    context.insert(session)
    for player in players {
      context.insert(PlayerScore(player: player, session: session))
    }
    return session
  }

  /// Finalizes a session: computes each player's category VP and total from the
  /// supplied raw inputs (keyed by `PlayerScore.id`), ranks them, records the
  /// results, and marks the session complete with its winners.
  static func finish(
    _ session: GameSession,
    game: any ScoringGame,
    inputs: [UUID: [String: Double]]
  ) {
    // Pass 1: compute category scores and totals.
    let computed = session.playerScores.map { score -> (PlayerScore, [String: Double], Double) in
      let raw = inputs[score.id] ?? [:]
      let categories = ScoringEngine.categoryScores(for: game, inputs: raw)
      return (score, categories, categories.values.reduce(0, +))
    }

    // Pass 2: rank by total + tiebreaker.
    let entries = computed.compactMap { score, categories, total -> RankingService.Entry? in
      guard let playerID = score.player?.id else { return nil }
      return RankingService.Entry(playerID: playerID, total: total, categoryScores: categories)
    }
    let ranking = RankingService.rank(game: game, entries: entries)

    // Pass 3: persist and complete.
    for (score, categories, total) in computed {
      let rank = score.player.flatMap { ranking.ranks[$0.id] } ?? 0
      score.record(
        totalScore: total,
        rank: rank,
        categoryScores: categories,
        rawInputs: inputs[score.id] ?? [:]
      )
    }
    session.complete(winnerIDs: ranking.winnerIDs)
  }
}
