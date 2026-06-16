import Foundation
import Testing
@testable import GameScoring

struct PlayerStatsTests {
  /// Builds a completed session of `game` with `players`; `winners` are the
  /// winning player IDs. `inProgress` leaves it unfinished.
  private func session(
    _ game: any ScoringGame,
    players: [Player],
    winners: [UUID],
    inProgress: Bool = false
  ) -> GameSession {
    let session = GameSession(gameID: game.id, gameName: game.name)
    for player in players {
      session.playerScores.append(PlayerScore(player: player, session: session))
    }
    if !inProgress { session.complete(winnerIDs: winners) }
    return session
  }

  private func player(_ name: String) -> Player {
    Player(name: name, avatarColor: "#888888")
  }

  @Test func countsGamesAndWins() {
    let ada = player("Ada"), boris = player("Boris")
    let sessions = [
      session(SevenWonders.shared, players: [ada, boris], winners: [ada.id]),
      session(Wingspan.shared, players: [ada, boris], winners: [boris.id]),
      session(Wingspan.shared, players: [ada, boris], winners: [ada.id]),
    ]
    let s = PlayerStats.summary(for: ada.id, in: sessions)
    #expect(s.gamesPlayed == 3)
    #expect(s.wins == 2)
    #expect(abs(s.winRate - 2.0 / 3.0) < 0.0001)
  }

  @Test func inProgressGamesAreExcluded() {
    let ada = player("Ada")
    let sessions = [
      session(Wingspan.shared, players: [ada], winners: [ada.id]),
      session(Wingspan.shared, players: [ada], winners: [], inProgress: true),
    ]
    #expect(PlayerStats.summary(for: ada.id, in: sessions).gamesPlayed == 1)
  }

  @Test func onlyCountsSessionsThePlayerWasIn() {
    let ada = player("Ada"), boris = player("Boris")
    let sessions = [
      session(SevenWonders.shared, players: [boris], winners: [boris.id]),  // no Ada
      session(SevenWonders.shared, players: [ada, boris], winners: [ada.id]),
    ]
    let s = PlayerStats.summary(for: ada.id, in: sessions)
    #expect(s.gamesPlayed == 1)
    #expect(s.wins == 1)
  }

  @Test func sharedWinCounts() {
    let ada = player("Ada"), boris = player("Boris")
    let tie = session(Wingspan.shared, players: [ada, boris], winners: [ada.id, boris.id])
    #expect(PlayerStats.summary(for: ada.id, in: [tie]).wins == 1)
  }

  @Test func perGameBreakdownSortedByPlays() {
    let ada = player("Ada")
    let sessions = [
      session(SevenWonders.shared, players: [ada], winners: [ada.id]),
      session(Wingspan.shared, players: [ada], winners: []),
      session(Wingspan.shared, players: [ada], winners: [ada.id]),
    ]
    let breakdown = PlayerStats.summary(for: ada.id, in: sessions).byGame
    #expect(breakdown.first?.gameID == "wingspan")  // 2 plays first
    #expect(breakdown.first?.played == 2)
    #expect(breakdown.first?.wins == 1)
  }

  @Test func emptyHistoryIsAllZero() {
    let s = PlayerStats.summary(for: UUID(), in: [])
    #expect(s.gamesPlayed == 0)
    #expect(s.wins == 0)
    #expect(s.winRate == 0)
    #expect(s.byGame.isEmpty)
  }
}
