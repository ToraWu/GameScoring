import Foundation

/// Wingspan base game scoring (no expansions).
///
/// All six categories are direct integer inputs — Wingspan has no derived VP.
/// The tiebreaker is the number of eggs on birds (official rulebook rule).
struct Wingspan: ScoringGame {
  static let shared = Wingspan()
  private init() {}

  let id = "wingspan"
  let name = "Wingspan"
  let artworkName = "Wingspan"
  let minPlayers = 1
  let maxPlayers = 5

  let categories: [ScoreCategory] = [
    ScoreCategory(id: "birds",      name: "Birds",       inputType: .integer, displayOrder: 0),
    ScoreCategory(id: "bonus",      name: "Bonus Cards", inputType: .integer, displayOrder: 1),
    ScoreCategory(id: "end_round",  name: "End-of-Round",inputType: .integer, displayOrder: 2),
    ScoreCategory(id: "eggs",       name: "Eggs",        inputType: .integer, displayOrder: 3),
    ScoreCategory(id: "food",       name: "Cached Food", inputType: .integer, displayOrder: 4),
    ScoreCategory(id: "tucked",     name: "Tucked Cards",inputType: .integer, displayOrder: 5),
  ]

  let tieBreaker: TieBreakerRule = .byCategory("eggs")

  /// Wingspan has no computed categories.
  func calculateScores(_ inputs: [String: Double]) -> [String: Double] { [:] }
}
