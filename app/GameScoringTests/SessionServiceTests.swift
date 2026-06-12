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

  @Test func finishRecordsTotalsRanksAndWinner() throws {
    let context = try makeContext()
    let players = seedPlayers(2, in: context)
    let session = SessionService.start(game: Wingspan.shared, players: players, in: context)

    // Map each player's score row to raw inputs.
    let scores = session.playerScores.sorted {
      ($0.player?.createdAt ?? .distantPast) < ($1.player?.createdAt ?? .distantPast)
    }
    let inputs: [UUID: [String: Double]] = [
      scores[0].id: ["birds": 40, "eggs": 5],   // 45
      scores[1].id: ["birds": 30, "eggs": 2],   // 32
    ]

    SessionService.finish(session, game: Wingspan.shared, inputs: inputs)

    #expect(!session.isInProgress)
    #expect(session.completedAt != nil)
    #expect(scores[0].totalScore == 45)
    #expect(scores[1].totalScore == 32)
    #expect(scores[0].rank == 1)
    #expect(scores[1].rank == 2)
    #expect(session.winnerIDs == [players[0].id])
  }

  @Test func finishWithATieSharesRankOne() throws {
    let context = try makeContext()
    let players = seedPlayers(3, in: context)
    let session = SessionService.start(game: Wingspan.shared, players: players, in: context)
    let scores = session.playerScores.sorted {
      ($0.player?.createdAt ?? .distantPast) < ($1.player?.createdAt ?? .distantPast)
    }

    // Players 0 and 1 tie exactly (same total and same eggs tiebreaker).
    SessionService.finish(session, game: Wingspan.shared, inputs: [
      scores[0].id: ["birds": 40, "eggs": 4],   // 44, eggs 4
      scores[1].id: ["birds": 40, "eggs": 4],   // 44, eggs 4
      scores[2].id: ["birds": 20, "eggs": 1],   // 21
    ])

    #expect(session.isTie)
    #expect(session.completedAt != nil)
    #expect(scores[0].rank == 1)
    #expect(scores[1].rank == 1)
    #expect(scores[2].rank == 3)  // competition ranking skips 2
    #expect(Set(session.winnerIDs) == [players[0].id, players[1].id])
  }

  @Test func finishComputesSevenWondersScienceIntoTotal() throws {
    let context = try makeContext()
    let players = seedPlayers(1, in: context)
    let session = SessionService.start(game: SevenWonders.shared, players: players, in: context)
    let score = session.playerScores[0]

    SessionService.finish(
      session,
      game: SevenWonders.shared,
      inputs: [score.id: ["military": 5, "compass": 1, "tablet": 1, "gear": 1]]
    )

    #expect(score.totalScore == 15)             // 5 military + 10 science
    #expect(score.categoryScores["science"] == 10)
    #expect(score.categoryScores["compass"] == nil)  // raw input not stored as a score
  }
}
