import XCTest

/// Verifies tapping a player's avatar opens their stats detail.
final class PlayerDetailUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  func testAvatarOpensStatsForWinner() {
    let app = XCUIApplication()
    app.launchFresh(completedGame: true)  // Ada beat Boris at 7 Wonders

    app.tabBars.buttons["Players"].tap()
    let avatar = app.buttons["playerAvatar.Ada"]
    waitFor(avatar, 10)
    avatar.tap()

    // Ada: 1 game, 1 win → 100% win rate, with a per-game breakdown.
    XCTAssertTrue(app.staticTexts["Win rate"].waitForExistence(timeout: 8))
    XCTAssertTrue(app.staticTexts["100%"].exists)
    XCTAssertTrue(app.staticTexts["By game"].exists)
    XCTAssertTrue(app.staticTexts["Recent games"].exists)

    let shot = XCTAttachment(screenshot: app.screenshot())
    shot.name = "PlayerDetail"
    shot.lifetime = .keepAlways
    add(shot)
  }

  func testAvatarOpensStatsForLoser() {
    let app = XCUIApplication()
    app.launchFresh(completedGame: true)

    app.tabBars.buttons["Players"].tap()
    let avatar = app.buttons["playerAvatar.Boris"]
    waitFor(avatar, 10)
    avatar.tap()

    // Boris: 1 game, 0 wins → 0%.
    XCTAssertTrue(app.staticTexts["Win rate"].waitForExistence(timeout: 8))
    XCTAssertTrue(app.staticTexts["0%"].exists)
  }
}
