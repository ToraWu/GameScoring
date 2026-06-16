import Foundation

/// Identifiable + Hashable wrapper so an `any ScoringGame` can drive item-based
/// presentation (`fullScreenCover(item:)`, `navigationDestination(item:)`).
/// Identity is the game's stable `id`.
struct GameRef: Identifiable, Hashable {
  let game: any ScoringGame
  var id: String { game.id }

  static func == (lhs: GameRef, rhs: GameRef) -> Bool { lhs.id == rhs.id }
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
