import Foundation
import SwiftData

/// Join entity linking a `Player` to a `GameSession` with their score breakdown.
/// Per-category values are stored as JSON so the schema is game-agnostic.
@Model
final class PlayerScore: Timestamped {
  @Attribute(.unique) var id: UUID
  var player: Player?
  var session: GameSession?

  // Fractional VP supported; negatives allowed for penalty-heavy games.
  var totalScore: Double { didSet { touch() } }

  // JSON-encoded `[String: Double]` keyed by category ID. Accessed through the
  // `categoryScores` computed property below.
  var categoryScoresData: Data

  // 1 = winner. Tied players share a rank using competition ranking (1, 1, 3).
  var rank: Int { didSet { touch() } }
  var updatedAt: Date

  init(
    id: UUID = UUID(),
    player: Player,
    session: GameSession,
    totalScore: Double = 0,
    categoryScores: [String: Double] = [:],
    rank: Int = 0
  ) {
    self.id = id
    self.player = player
    self.session = session
    self.totalScore = totalScore
    self.categoryScoresData = Self.encode(categoryScores)
    self.rank = rank
    self.updatedAt = .now
  }

  /// Per-category VP keyed by `ScoreCategory.id`. Reads decode the stored JSON;
  /// writes re-encode it and bump `updatedAt`.
  var categoryScores: [String: Double] {
    get {
      (try? JSONDecoder().decode([String: Double].self, from: categoryScoresData)) ?? [:]
    }
    set {
      categoryScoresData = Self.encode(newValue)
      touch()
    }
  }

  private static func encode(_ scores: [String: Double]) -> Data {
    (try? JSONEncoder().encode(scores)) ?? Data("{}".utf8)
  }
}
