import XCTest

/// Covers the Results-screen flows: revise scores after finishing, and replay
/// with the same players.
final class ResultsFlowUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  /// Start 7 Wonders with Ada + Boris, give Ada `adaMilitary` and Boris
  /// `borisMilitary`, then finish. Leaves the app on Results.
  private func playToResults(_ app: XCUIApplication, adaMilitary: Int, borisMilitary: Int) {
    app.launchFresh(seedPlayers: true)
    app.tabBars.buttons["Shelf"].tap()
    let card = app.buttons["game.7wonders"]
    waitFor(card)
    card.tap()
    app.buttons["roster.Ada"].tap()
    app.buttons["roster.Boris"].tap()
    app.buttons["setup.start"].tap()

    let plus = app.buttons["military.plus"]
    waitFor(plus, 10)
    for _ in 0..<adaMilitary { plus.tap() }
    app.buttons["scoring.next"].tap()
    let borisPlus = app.buttons["military.plus"]
    waitFor(borisPlus)
    for _ in 0..<borisMilitary { borisPlus.tap() }
    app.buttons["scoring.finish"].tap()
  }

  func testEditRevisesAndReRanks() {
    let app = XCUIApplication()
    playToResults(app, adaMilitary: 7, borisMilitary: 3)
    XCTAssertTrue(app.staticTexts["Ada wins!"].waitForExistence(timeout: 8))

    // Edit → back to Score Entry (still on Boris, the last player).
    app.buttons["results.edit"].tap()
    let borisPlus = app.buttons["military.plus"]
    waitFor(borisPlus, 8, "did not return to scoring")
    for _ in 0..<8 { borisPlus.tap() }  // Boris 3 → 11, now beats Ada's 7

    app.buttons["scoring.finish"].tap()
    XCTAssertTrue(app.staticTexts["Boris wins!"].waitForExistence(timeout: 8))
  }

  func testPlayAgainPreloadsSamePlayers() {
    let app = XCUIApplication()
    playToResults(app, adaMilitary: 5, borisMilitary: 2)
    waitFor(app.buttons["results.playAgain"], 8)

    app.buttons["results.playAgain"].tap()

    // Setup re-opens with both players pre-selected (count shows 2 / 7).
    XCTAssertTrue(app.staticTexts["2 / 7"].waitForExistence(timeout: 8))
    XCTAssertTrue(app.buttons["setup.start"].isEnabled)
  }
}
