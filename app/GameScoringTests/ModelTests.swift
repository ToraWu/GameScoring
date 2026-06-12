import Foundation
import Testing
@testable import GameScoring

struct PlayerTests {
  @Test func newPlayerIsActive() {
    let player = Player(name: "Ada", avatarColor: "#e11d48")
    #expect(player.isActive)
    #expect(player.deletedAt == nil)
  }

  @Test func softDeleteMarksInactiveAndTouches() {
    let player = Player(name: "Ada", avatarColor: "#e11d48")
    player.updatedAt = .distantPast
    player.softDelete()
    #expect(!player.isActive)
    #expect(player.deletedAt != nil)
    #expect(player.updatedAt > .distantPast)
  }

  @Test func renameChangesNameAndBumpsUpdatedAt() {
    let player = Player(name: "Ada", avatarColor: "#e11d48")
    player.updatedAt = .distantPast
    player.rename(to: "Adaeze")
    #expect(player.name == "Adaeze")
    #expect(player.updatedAt > .distantPast)
  }

  @Test func setAvatarColorChangesColorAndBumpsUpdatedAt() {
    let player = Player(name: "Ada", avatarColor: "#e11d48")
    player.updatedAt = .distantPast
    player.setAvatarColor("#0891b2")
    #expect(player.avatarColor == "#0891b2")
    #expect(player.updatedAt > .distantPast)
  }
}

struct GameSessionTests {
  @Test func newSessionIsInProgress() {
    let session = GameSession(gameID: "7wonders", gameName: "7 Wonders")
    #expect(session.isInProgress)
    #expect(session.completedAt == nil)
    #expect(!session.isTie)
  }

  @Test func completingSetsWinnersAndTimestamp() {
    let session = GameSession(gameID: "7wonders", gameName: "7 Wonders")
    session.updatedAt = .distantPast
    let winner = UUID()
    session.complete(winnerIDs: [winner])
    #expect(!session.isInProgress)
    #expect(session.completedAt != nil)
    #expect(session.winnerIDs == [winner])
    #expect(session.updatedAt > .distantPast)
  }

  @Test func multipleWinnersIsATie() {
    let session = GameSession(gameID: "wingspan", gameName: "Wingspan")
    session.complete(winnerIDs: [UUID(), UUID()])
    #expect(session.isTie)
  }
}

struct PlayerScoreTests {
  private func makeScore(_ categories: [String: Double] = [:]) -> PlayerScore {
    PlayerScore(
      player: Player(name: "Ada", avatarColor: "#e11d48"),
      session: GameSession(gameID: "7wonders", gameName: "7 Wonders"),
      categoryScores: categories
    )
  }

  @Test func categoryScoresDefaultEmpty() {
    #expect(makeScore().categoryScores.isEmpty)
  }

  @Test func categoryScoresRoundTrip() {
    let score = makeScore(["military": 6, "science": 10, "treasury": 3.5])
    #expect(score.categoryScores["military"] == 6)
    #expect(score.categoryScores["science"] == 10)
    #expect(score.categoryScores["treasury"] == 3.5)
  }

  @Test func settingCategoryScoresReEncodesAndTouches() {
    let score = makeScore()
    score.updatedAt = .distantPast
    score.categoryScores = ["birds": 12]
    #expect(score.categoryScores["birds"] == 12)
    #expect(score.updatedAt > .distantPast)
  }

  @Test func recordWritesAllFieldsAndTouches() {
    let score = makeScore()
    score.updatedAt = .distantPast
    score.record(totalScore: 42, rank: 1, categoryScores: ["military": 6, "science": 10])
    #expect(score.totalScore == 42)
    #expect(score.rank == 1)
    #expect(score.categoryScores["science"] == 10)
    #expect(score.updatedAt > .distantPast)
  }
}
