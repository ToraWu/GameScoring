import Foundation
import Testing
@testable import GameScoring

struct RankingServiceTests {
  private func entry(_ total: Double, treasury: Double = 0) -> RankingService.Entry {
    RankingService.Entry(
      playerID: UUID(),
      total: total,
      categoryScores: ["treasury": treasury]
    )
  }

  @Test func clearWinnerRanksOneToThree() {
    let a = entry(50), b = entry(40), c = entry(30)
    let result = RankingService.rank(game: SevenWonders.shared, entries: [a, b, c])
    #expect(result.ranks[a.playerID] == 1)
    #expect(result.ranks[b.playerID] == 2)
    #expect(result.ranks[c.playerID] == 3)
    #expect(result.winnerIDs == [a.playerID])
  }

  @Test func tieIsBrokenByTreasuryCategory() {
    // 7 Wonders breaks ties by treasury (most coins).
    let a = entry(50, treasury: 3)
    let b = entry(50, treasury: 7)
    let result = RankingService.rank(game: SevenWonders.shared, entries: [a, b])
    #expect(result.ranks[b.playerID] == 1)
    #expect(result.ranks[a.playerID] == 2)
    #expect(result.winnerIDs == [b.playerID])
  }

  @Test func equalTotalAndTiebreakerIsASharedWin() {
    let a = entry(50, treasury: 4)
    let b = entry(50, treasury: 4)
    let c = entry(30)
    let result = RankingService.rank(game: SevenWonders.shared, entries: [a, b, c])
    #expect(result.ranks[a.playerID] == 1)
    #expect(result.ranks[b.playerID] == 1)
    #expect(result.ranks[c.playerID] == 3)  // competition ranking: 1, 1, 3
    #expect(Set(result.winnerIDs) == [a.playerID, b.playerID])
  }

  @Test func tiebreakerOnlyAppliesToEqualTotals() {
    // Higher total wins even with a lower treasury.
    let a = entry(60, treasury: 0)
    let b = entry(50, treasury: 9)
    let result = RankingService.rank(game: SevenWonders.shared, entries: [a, b])
    #expect(result.winnerIDs == [a.playerID])
  }

  @Test func wingspanTieWithoutSeparationIsShared() {
    // Wingspan breaks ties by eggs; equal eggs → shared win.
    let a = RankingService.Entry(playerID: UUID(), total: 70, categoryScores: ["eggs": 4])
    let b = RankingService.Entry(playerID: UUID(), total: 70, categoryScores: ["eggs": 4])
    let result = RankingService.rank(game: Wingspan.shared, entries: [a, b])
    #expect(Set(result.winnerIDs) == [a.playerID, b.playerID])
  }
}
