import Foundation
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

struct CarcassonneScoringTests {
  @Test func hasNoComputedCategories() {
    let result = Carcassonne.shared.calculateScores(["cities": 20, "roads": 8])
    #expect(result.isEmpty)
  }

  @Test func totalSumsAllFourCategories() {
    let total = ScoringEngine.total(for: Carcassonne.shared, inputs: [
      "cities": 24, "roads": 10, "cloisters": 9, "fields": 15,
    ])
    #expect(total == 58)
  }

  @Test func tiesAreSharedWithNoTiebreaker() {
    let a = RankingService.Entry(playerID: UUID(), total: 58, categoryScores: [:])
    let b = RankingService.Entry(playerID: UUID(), total: 58, categoryScores: [:])
    let result = RankingService.rank(game: Carcassonne.shared, entries: [a, b])
    #expect(Set(result.winnerIDs) == [a.playerID, b.playerID])
  }
}

struct TicketToRideScoringTests {
  private let game = TicketToRide.shared

  @Test func ticketsAllowNegativeButRoutesDoNot() {
    #expect(game.categories.first { $0.id == "tickets" }?.allowsNegative == true)
    #expect(game.categories.first { $0.id == "routes" }?.allowsNegative == false)
  }

  @Test func uncompletedTicketsSubtractFromTotal() {
    // 60 route points + 10 longest − 8 ticket penalty = 62.
    let total = ScoringEngine.total(for: game, inputs: [
      "routes": 60, "longest": 10, "tickets": -8,
    ])
    #expect(total == 62)
  }

  @Test func tiesBreakByTickets() {
    let a = RankingService.Entry(playerID: UUID(), total: 70, categoryScores: ["tickets": 12])
    let b = RankingService.Entry(playerID: UUID(), total: 70, categoryScores: ["tickets": 20])
    let result = RankingService.rank(game: game, entries: [a, b])
    #expect(result.winnerIDs == [b.playerID])
  }
}

struct GameRegistryTests {
  @Test func registersAllGames() {
    #expect(GameRegistry.all.count == 4)
  }

  @Test func looksUpByID() {
    #expect(GameRegistry.game(for: "7wonders")?.name == "7 Wonders")
    #expect(GameRegistry.game(for: "wingspan")?.name == "Wingspan")
    #expect(GameRegistry.game(for: "carcassonne")?.name == "Carcassonne")
    #expect(GameRegistry.game(for: "tickettoride")?.name == "Ticket to Ride")
  }

  @Test func unknownIDReturnsNil() {
    #expect(GameRegistry.game(for: "monopoly") == nil)
  }

  @Test func playerBoundsMatchSpec() {
    #expect(SevenWonders.shared.minPlayers == 2)
    #expect(SevenWonders.shared.maxPlayers == 7)
    #expect(Wingspan.shared.minPlayers == 1)
    #expect(Wingspan.shared.maxPlayers == 5)
    #expect(Carcassonne.shared.minPlayers == 2)
    #expect(Carcassonne.shared.maxPlayers == 5)
  }

  @Test func everyCategoryHasIconAndColour() {
    for game in GameRegistry.all {
      for category in game.categories {
        #expect(!category.icon.isEmpty)
        #expect(category.colorHex.hasPrefix("#"))
      }
    }
  }

  @Test func sevenWondersMilitaryAllowsNegative() {
    let military = SevenWonders.shared.categories.first { $0.id == "military" }
    #expect(military?.allowsNegative == true)
    // Direct-VP categories without penalties stay non-negative.
    let treasury = SevenWonders.shared.categories.first { $0.id == "treasury" }
    #expect(treasury?.allowsNegative == false)
  }
}
