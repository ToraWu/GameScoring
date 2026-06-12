import Foundation

/// Turns a player's raw category inputs into final per-category VP and a total.
///
/// Some integer inputs feed a computed category rather than scoring directly
/// (e.g. 7 Wonders science symbols feed `science`). Those "input-only"
/// categories are excluded from `categoryScores` and the total.
enum ScoringEngine {
  /// IDs of categories that are pure inputs to a `.computed` category, and so
  /// do not score on their own.
  static func inputOnlyIDs(for game: any ScoringGame) -> Set<String> {
    var ids = Set<String>()
    for category in game.categories {
      if case .computed(let sources) = category.inputType {
        ids.formUnion(sources)
      }
    }
    return ids
  }

  /// Final VP per scoring category for one player's raw `inputs`. Computed
  /// categories use the game's formula; direct categories use the raw value.
  static func categoryScores(
    for game: any ScoringGame,
    inputs: [String: Double]
  ) -> [String: Double] {
    let computed = game.calculateScores(inputs)
    let inputOnly = inputOnlyIDs(for: game)

    var result: [String: Double] = [:]
    for category in game.categories where !inputOnly.contains(category.id) {
      switch category.inputType {
      case .computed:
        result[category.id] = computed[category.id] ?? 0
      case .integer, .checkbox:
        result[category.id] = inputs[category.id] ?? 0
      }
    }
    return result
  }

  /// Sum of all scoring categories for one player's raw `inputs`.
  static func total(for game: any ScoringGame, inputs: [String: Double]) -> Double {
    categoryScores(for: game, inputs: inputs).values.reduce(0, +)
  }
}
