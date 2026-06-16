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
  // Written via `record(...)`; `didSet` does not fire on @Model properties.
  var totalScore: Double

  // JSON-encoded computed VP `[String: Double]` keyed by category ID. Accessed
  // through the `categoryScores` computed property below.
  var categoryScoresData: Data

  // JSON-encoded raw inputs `[String: Double]` — exactly what the user typed,
  // kept so a finished game can be re-opened and revised (Results → Edit).
  var rawInputsData: Data

  // 1 = winner. Tied players share a rank using competition ranking (1, 1, 3).
  var rank: Int
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
    self.rawInputsData = Self.encode([:])
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

  /// Raw inputs the user entered, keyed by category ID. Persisted live during
  /// scoring so an in-progress or finished game can be resumed/revised.
  var rawInputs: [String: Double] {
    get {
      (try? JSONDecoder().decode([String: Double].self, from: rawInputsData)) ?? [:]
    }
    set {
      rawInputsData = Self.encode(newValue)
      touch()
    }
  }

  /// Writes the computed result of a scoring pass and bumps `updatedAt` once.
  /// `rawInputs` are the user's entries that produced these scores.
  func record(
    totalScore: Double,
    rank: Int,
    categoryScores: [String: Double],
    rawInputs: [String: Double]
  ) {
    self.totalScore = totalScore
    self.rank = rank
    self.categoryScoresData = Self.encode(categoryScores)
    self.rawInputsData = Self.encode(rawInputs)
    touch()
  }

  private static func encode(_ scores: [String: Double]) -> Data {
    (try? JSONEncoder().encode(scores)) ?? Data("{}".utf8)
  }
}
