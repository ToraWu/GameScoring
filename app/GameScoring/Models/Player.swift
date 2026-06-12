import Foundation
import SwiftData

/// A persistent player profile, reused across any game. Deleted profiles are
/// soft-deleted (`deletedAt`) so their name survives in past game history.
@Model
final class Player: Timestamped {
  // `.unique` gives local upsert semantics. The client-generated UUID already
  // guarantees uniqueness; drop this attribute if CloudKit sync is added later.
  @Attribute(.unique) var id: UUID
  // Plain stored properties (predicate/sort friendly). `updatedAt` is bumped
  // through the mutation methods below — property observers (`didSet`) do NOT
  // fire on @Model stored properties, so touch() must be called explicitly.
  var name: String
  var avatarColor: String
  var createdAt: Date
  var updatedAt: Date
  var deletedAt: Date?

  // Scores are never cascade-deleted with a player — nullify keeps history rows
  // intact. In practice players are soft-deleted, so this rarely fires.
  @Relationship(deleteRule: .nullify, inverse: \PlayerScore.player)
  var scores: [PlayerScore] = []

  init(
    id: UUID = UUID(),
    name: String,
    avatarColor: String,
    createdAt: Date = .now
  ) {
    self.id = id
    self.name = name
    self.avatarColor = avatarColor
    self.createdAt = createdAt
    self.updatedAt = createdAt
    self.deletedAt = nil
  }

  /// True while the player is in the active roster (not soft-deleted).
  var isActive: Bool {
    deletedAt == nil
  }

  /// Renames the player and bumps `updatedAt`.
  func rename(to newName: String) {
    name = newName
    touch()
  }

  /// Changes the avatar color and bumps `updatedAt`.
  func setAvatarColor(_ hex: String) {
    avatarColor = hex
    touch()
  }

  /// Marks the player as removed from the roster while preserving history.
  func softDelete() {
    deletedAt = .now
    touch()
  }
}
