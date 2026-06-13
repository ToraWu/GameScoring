import Foundation
import SwiftData
import Testing
@testable import GameScoring

struct HistoryStatsTests {
  /// Builds a session with the given game and player names. Completed unless
  /// `inProgress` is true.
  private func makeSession(
    game: any ScoringGame,
    players: [String],
    inProgress: Bool = false
  ) -> GameSession {
    let session = GameSession(gameID: game.id, gameName: game.name)
    for name in players {
      let player = Player(name: name, avatarColor: "#888888")
      let score = PlayerScore(player: player, session: session)
      session.playerScores.append(score)
    }
    if !inProgress { session.complete(winnerIDs: []) }
    return session
  }

  @Test func playCountsTallyCompletedGamesPerGameID() {
    let sessions = [
      makeSession(game: SevenWonders.shared, players: ["Ada"]),
      makeSession(game: SevenWonders.shared, players: ["Boris"]),
      makeSession(game: Wingspan.shared, players: ["Chen"]),
    ]
    let counts = HistoryStats.playCounts(sessions)
    #expect(counts["7wonders"] == 2)
    #expect(counts["wingspan"] == 1)
  }

  @Test func playCountsIgnoreInProgressSessions() {
    let sessions = [
      makeSession(game: Wingspan.shared, players: ["Ada"]),
      makeSession(game: Wingspan.shared, players: ["Boris"], inProgress: true),
    ]
    #expect(HistoryStats.playCounts(sessions)["wingspan"] == 1)
  }

  @Test func mostPlayedReturnsHighestCount() {
    let sessions = [
      makeSession(game: SevenWonders.shared, players: ["Ada"]),
      makeSession(game: Wingspan.shared, players: ["Boris"]),
      makeSession(game: Wingspan.shared, players: ["Chen"]),
    ]
    #expect(HistoryStats.mostPlayedGameID(sessions) == "wingspan")
  }

  @Test func mostPlayedIsNilWithNoCompletedGames() {
    #expect(HistoryStats.mostPlayedGameID([]) == nil)
  }

  @Test func emptyQueryMatchesEverything() {
    let session = makeSession(game: SevenWonders.shared, players: ["Ada"])
    #expect(HistoryStats.matches(session, query: ""))
    #expect(HistoryStats.matches(session, query: "   "))
  }

  @Test func queryMatchesGameNameCaseInsensitively() {
    let session = makeSession(game: SevenWonders.shared, players: ["Ada"])
    #expect(HistoryStats.matches(session, query: "wonders"))
    #expect(!HistoryStats.matches(session, query: "wingspan"))
  }

  @Test func queryMatchesPlayerName() {
    let session = makeSession(game: Wingspan.shared, players: ["Ada", "Boris"])
    #expect(HistoryStats.matches(session, query: "bor"))
    #expect(!HistoryStats.matches(session, query: "chen"))
  }
}
