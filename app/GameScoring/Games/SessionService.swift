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
}
