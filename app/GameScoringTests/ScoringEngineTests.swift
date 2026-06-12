import Testing
@testable import GameScoring

struct ScoringEngineTests {
  private let sevenWonders = SevenWonders.shared
  private let wingspan = Wingspan.shared

  @Test func inputOnlyIDsAreTheScienceSymbols() {
    let ids = ScoringEngine.inputOnlyIDs(for: sevenWonders)
    #expect(ids == ["compass", "tablet", "gear", "sci_wild"])
  }

  @Test func wingspanHasNoInputOnlyCategories() {
    #expect(ScoringEngine.inputOnlyIDs(for: wingspan).isEmpty)
  }

  @Test func scienceSymbolsAreExcludedFromCategoryScores() {
    let scores = ScoringEngine.categoryScores(
      for: sevenWonders,
      inputs: ["military": 5, "compass": 1, "tablet": 1, "gear": 1]
    )
    #expect(scores["military"] == 5)
    #expect(scores["science"] == 10)   // 1 of each → 7 + 3
    #expect(scores["compass"] == nil)  // pure input, not a scoring category
    #expect(scores["tablet"] == nil)
  }

  @Test func totalExcludesInputsAndIncludesComputedVP() {
    // military 5 + science 10 (from 1/1/1) = 15; symbols don't add themselves.
    let total = ScoringEngine.total(
      for: sevenWonders,
      inputs: ["military": 5, "compass": 1, "tablet": 1, "gear": 1]
    )
    #expect(total == 15)
  }

  @Test func wingspanTotalIsTheSumOfAllSixCategories() {
    let inputs: [String: Double] = [
      "birds": 12, "bonus": 5, "end_round": 8, "eggs": 4, "food": 3, "tucked": 2,
    ]
    #expect(ScoringEngine.total(for: wingspan, inputs: inputs) == 34)
  }

  @Test func missingInputsCountAsZero() {
    #expect(ScoringEngine.total(for: wingspan, inputs: [:]) == 0)
  }
}
