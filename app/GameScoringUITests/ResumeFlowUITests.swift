import XCTest

/// Verifies the Home resume banner re-enters the in-progress game.
final class ResumeFlowUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  func testResumeBannerReentersScoring() {
    let app = XCUIApplication()
    app.launchFresh(inProgressGame: true)

    let resume = app.buttons["home.resume"]
    XCTAssertTrue(resume.waitForExistence(timeout: 10), "resume banner not shown")
    resume.tap()

    // Back in Score Entry for the in-progress 7 Wonders game.
    waitFor(app.buttons["military.plus"], 10, "did not resume into scoring")
    XCTAssertTrue(app.staticTexts["scoring.total"].exists)
  }

  func testNoResumeBannerWhenNothingInProgress() {
    let app = XCUIApplication()
    app.launchFresh(seedPlayers: true)  // roster but no in-progress game

    XCTAssertTrue(app.staticTexts["BoardScore"].waitForExistence(timeout: 10))
    XCTAssertFalse(app.buttons["home.resume"].exists)
  }
}
