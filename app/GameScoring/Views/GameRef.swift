import Foundation

/// Identifiable wrapper so an `any ScoringGame` can drive item-based
/// presentation (`fullScreenCover(item:)`, `sheet(item:)`).
struct GameRef: Identifiable {
  let game: any ScoringGame
  var id: String { game.id }
}
