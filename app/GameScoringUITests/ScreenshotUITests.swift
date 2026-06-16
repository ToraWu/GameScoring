import XCTest

/// Captures screenshots of the redesigned screens as test attachments for
/// visual review. Not assertions — purely for eyeballing the result.
final class ScreenshotUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  private func snap(_ app: XCUIApplication, _ name: String) {
    let shot = XCTAttachment(screenshot: app.screenshot())
    shot.name = name
    shot.lifetime = .keepAlways
    add(shot)
  }

  func testCaptureScoringAndResults() {
    let app = XCUIApplication()
    app.launchFresh(seedPlayers: true)
    app.tabBars.buttons["Shelf"].tap()
    app.buttons["game.7wonders"].tap()
    app.buttons["roster.Ada"].tap()
    app.buttons["roster.Boris"].tap()
    app.buttons["setup.start"].tap()

    let plus = app.buttons["military.plus"]
    waitFor(plus, 10)
    for _ in 0..<7 { plus.tap() }
    app.buttons["treasury.plus"].tap()
    app.buttons["treasury.plus"].tap()
    snap(app, "ScoreEntry")

    // Open the in-app keypad on a category and capture it.
    app.buttons["civilian.value"].tap()
    waitFor(app.buttons["keypad.7"], 8)
    app.buttons["keypad.7"].tap()
    snap(app, "Keypad")
    app.buttons["keypad.done"].tap()

    app.buttons["scoring.next"].tap()
    let borisPlus = app.buttons["military.plus"]
    waitFor(borisPlus)
    for _ in 0..<3 { borisPlus.tap() }
    app.buttons["scoring.finish"].tap()

    waitFor(app.staticTexts["Ada wins!"], 8)
    snap(app, "Results")
  }
}
