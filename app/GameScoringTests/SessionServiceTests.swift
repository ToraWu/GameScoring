import Foundation
import SwiftData
import Testing
@testable import GameScoring

struct SessionServiceTests {
  /// A fresh on-disk store in a unique temp location per test. An in-memory
  /// store can't be used here because SwiftData's `@Attribute(.unique)`
  /// constraints are unsupported in memory-only stores.
  private func makeContext() throws -> ModelContext {
    let schema = Schema([Player.self, GameSession.self, PlayerScore.self])
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("\(UUID().uuidString).store")
    let config = ModelConfiguration(url: url)
    let container = try ModelContainer(for: schema, configurations: [config])
    return ModelContext(container)
  }

  private func seedPlayers(_ count: Int, in context: ModelContext) -> [Player] {
    (0..<count).map { i in
      let player = Player(name: "P\(i)", avatarColor: Theme.avatarPalette[i % 8])
      context.insert(player)
      return player
    }
  }

  private func sessions(in context: ModelContext) throws -> [GameSession] {
    try context.fetch(FetchDescriptor<GameSession>())
  }

  @Test func startCreatesSessionWithOneScorePerPlayer() throws {
    let context = try makeContext()
    let players = seedPlayers(4, in: context)

    let session = SessionService.start(game: SevenWonders.shared, players: players, in: context)

    #expect(session.gameID == "7wonders")
    #expect(session.gameName == "7 Wonders")
    #expect(session.playerScores.count == 4)
    #expect(try sessions(in: context).count == 1)
    #expect(session.isInProgress)
  }

  @Test func inProgressReturnsTheActiveSession() throws {
    let context = try makeContext()
    let players = seedPlayers(2, in: context)
    let started = SessionService.start(game: Wingspan.shared, players: players, in: context)

    #expect(SessionService.inProgress(in: context)?.id == started.id)
  }

  @Test func startingAnotherDiscardsPreviousInProgress() throws {
    let context = try makeContext()
    let players = seedPlayers(4, in: context)

    SessionService.start(game: SevenWonders.shared, players: players, in: context)
    SessionService.start(game: Wingspan.shared, players: Array(players.prefix(2)), in: context)

    let all = try sessions(in: context)
    #expect(all.count == 1)  // previous in-progress session was discarded
    #expect(all.first?.gameID == "wingspan")
    #expect(all.first?.playerScores.count == 2)
  }

  @Test func completedSessionsAreKeptWhenStartingANewOne() throws {
    let context = try makeContext()
    let players = seedPlayers(3, in: context)

    let first = SessionService.start(game: SevenWonders.shared, players: players, in: context)
    first.complete(winnerIDs: [players[0].id])  // finished — must survive

    SessionService.start(game: Wingspan.shared, players: players, in: context)

    let all = try sessions(in: context)
    #expect(all.count == 2)  // completed one kept, new in-progress one added
    #expect(SessionService.inProgress(in: context)?.gameID == "wingspan")
  }

  @Test func inProgressIsNilWhenNoneActive() throws {
    let context = try makeContext()
    let players = seedPlayers(2, in: context)
    let session = SessionService.start(game: Wingspan.shared, players: players, in: context)
    session.complete(winnerIDs: [players[0].id])

    #expect(SessionService.inProgress(in: context) == nil)
  }
}
