import Foundation

/// Central lookup for all supported games.
enum GameRegistry {
  static let all: [any ScoringGame] = [
    SevenWonders.shared,
    Wingspan.shared,
    Carcassonne.shared,
  ]

  static func game(for id: String) -> (any ScoringGame)? {
    all.first { $0.id == id }
  }
}
