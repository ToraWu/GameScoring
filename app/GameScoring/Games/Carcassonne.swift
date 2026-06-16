import Foundation

/// Carcassonne base game scoring (no expansions).
///
/// Final scores are entered as four direct VP totals — cities, roads,
/// cloisters, and fields. There's no official tiebreaker, so a tie is a shared
/// win.
struct Carcassonne: ScoringGame {
  static let shared = Carcassonne()
  private init() {}

  let id = "carcassonne"
  let name = "Carcassonne"
  let artworkName = "Carcassonne"
  let minPlayers = 2
  let maxPlayers = 5

  let categories: [ScoreCategory] = [
    ScoreCategory(id: "cities", name: "Cities", inputType: .integer, displayOrder: 0,
                  icon: "building.2.fill", colorHex: "#b5562a"),
    ScoreCategory(id: "roads", name: "Roads", inputType: .integer, displayOrder: 1,
                  icon: "road.lanes", colorHex: "#7a7066"),
    ScoreCategory(id: "cloisters", name: "Cloisters", inputType: .integer, displayOrder: 2,
                  icon: "building.columns.fill", colorHex: "#8a6d3b"),
    ScoreCategory(id: "fields", name: "Fields", inputType: .integer, displayOrder: 3,
                  icon: "leaf.fill", colorHex: "#5a9e4a"),
  ]

  let tieBreaker: TieBreakerRule = .none

  /// Carcassonne has no computed categories.
  func calculateScores(_ inputs: [String: Double]) -> [String: Double] { [:] }
}
