import Testing
@testable import GameScoring

struct SevenWondersScienceTests {
  private let game = SevenWonders.shared

  /// Convenience: run the science formula for raw symbol counts.
  private func science(compass: Int, tablet: Int, gear: Int, wild: Int = 0) -> Double {
    game.calculateScores([
      "compass": Double(compass),
      "tablet": Double(tablet),
      "gear": Double(gear),
      "sci_wild": Double(wild),
    ])["science"] ?? .nan
  }

  @Test func noSymbolsScoreZero() {
    #expect(science(compass: 0, tablet: 0, gear: 0) == 0)
  }

  @Test func oneOfEachIsSetPlusSquares() {
    // sets=1 → 7, plus 1²+1²+1² = 3  →  10
    #expect(science(compass: 1, tablet: 1, gear: 1) == 10)
  }

  @Test func squaresWithoutASet() {
    // sets=0 → 0, plus 3² = 9
    #expect(science(compass: 3, tablet: 0, gear: 0) == 9)
  }

  @Test func unevenCounts() {
    // sets=1 → 7, plus 2²+1²+1² = 6  →  13
    #expect(science(compass: 2, tablet: 1, gear: 1) == 13)
  }

  @Test func wildcardCompletesASet() {
    // c1 t1 g0 + 1 wild → best is to make the gear: sets=1 → 7 + 1+1+1 = 10
    #expect(science(compass: 1, tablet: 1, gear: 0, wild: 1) == 10)
  }

  @Test func pureWildcardsSpreadForASet() {
    // 3 wild, nothing else → one of each: sets=1 → 7 + 3 = 10 (beats 3²=9)
    #expect(science(compass: 0, tablet: 0, gear: 0, wild: 3) == 10)
  }

  @Test func wildcardStacksWhenStackingWins() {
    // c2 t2 g2 + 1 wild → adding to any one: sets=2 →14, plus 3²+2²+2²=17 → 31
    #expect(science(compass: 2, tablet: 2, gear: 2, wild: 1) == 31)
  }

  @Test func onlyComputesScienceKey() {
    let result = game.calculateScores([
      "compass": 1, "tablet": 1, "gear": 1,
      "military": 5, "treasury": 9,  // direct inputs must be ignored
    ])
    #expect(Array(result.keys) == ["science"])
  }
}

struct WingspanScoringTests {
  @Test func hasNoComputedCategories() {
    let result = Wingspan.shared.calculateScores([
      "birds": 12, "eggs": 4, "food": 3,
    ])
    #expect(result.isEmpty)
  }
}

struct GameRegistryTests {
  @Test func registersBothGames() {
    #expect(GameRegistry.all.count == 2)
  }

  @Test func looksUpByID() {
    #expect(GameRegistry.game(for: "7wonders")?.name == "7 Wonders")
    #expect(GameRegistry.game(for: "wingspan")?.name == "Wingspan")
  }

  @Test func unknownIDReturnsNil() {
    #expect(GameRegistry.game(for: "catan") == nil)
  }

  @Test func playerBoundsMatchSpec() {
    #expect(SevenWonders.shared.minPlayers == 2)
    #expect(SevenWonders.shared.maxPlayers == 7)
    #expect(Wingspan.shared.minPlayers == 1)
    #expect(Wingspan.shared.maxPlayers == 5)
  }
}
