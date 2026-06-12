import Foundation
import SwiftData

/// One play of a game. `gameID` is a plain string (never a typed reference) so
/// history stays game-agnostic and new games need no schema migration.
@Model
final class GameSession: Timestamped {
  @Attribute(.unique) var id: UUID
  var gameID: String
  var gameName: String
  var createdAt: Date
  var completedAt: Date?
  var updatedAt: Date

  // `Player.id` snapshots — survive player deletion. One entry = solo winner;
  // multiple = a shared (tied) victory.
  var winnerIDs: [UUID]

  @Relationship(deleteRule: .cascade, inverse: \PlayerScore.session)
  var playerScores: [PlayerScore] = []

  init(
    id: UUID = UUID(),
    gameID: String,
    gameName: String,
    createdAt: Date = .now,
    winnerIDs: [UUID] = []
  ) {
    self.id = id
    self.gameID = gameID
    self.gameName = gameName
    self.createdAt = createdAt
    self.completedAt = nil
    self.updatedAt = createdAt
    self.winnerIDs = winnerIDs
  }

  /// nil `completedAt` means the session is still in progress and resumable.
  var isInProgress: Bool {
    completedAt == nil
  }

  /// A shared victory between two or more players.
  var isTie: Bool {
    winnerIDs.count > 1
  }

  /// Marks the session finished with its final winners.
  func complete(winnerIDs: [UUID]) {
    self.winnerIDs = winnerIDs
    completedAt = .now
    touch()
  }
}
