import XCTest

/// Drives the full score-entry flow: start a game, enter scores with the
/// steppers, and finish to the Results screen.
final class ScoringFlowUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  /// Navigates Shelf → game → selects two seeded players → Start. Leaves the
  /// app on the Score Entry screen.
  private func startTwoPlayerGame(_ app: XCUIApplication, gameID: String = "7wonders") {
    app.launchFresh(seedPlayers: true)
    app.tabBars.buttons["Shelf"].tap()
    let card = app.buttons["game.\(gameID)"]
    waitFor(card)
    card.tap()
    app.buttons["roster.Ada"].tap()
    app.buttons["roster.Boris"].tap()
    app.buttons["setup.start"].tap()
  }

  func testScoreTwoPlayersAndFinish() {
    let app = XCUIApplication()
    startTwoPlayerGame(app)

    let plus = app.buttons["military.plus"]
    waitFor(plus, 10, "scoring screen did not appear")

    // Ada: military = 7 → total 7 VP.
    for _ in 0..<7 { plus.tap() }
    XCTAssertEqual(app.buttons["military.value"].label, "7")
    XCTAssertEqual(app.staticTexts["scoring.total"].label, "7 VP")

    // Advance to Boris (last player → button is Finish).
    app.buttons["scoring.next"].tap()
    let borisPlus = app.buttons["military.plus"]
    waitFor(borisPlus)
    for _ in 0..<3 { borisPlus.tap() }

    let finish = app.buttons["scoring.finish"]
    XCTAssertTrue(finish.exists, "last player should show Finish, not Next")
    finish.tap()

    // Results: Ada (7) beats Boris (3).
    XCTAssertTrue(app.staticTexts["Ada wins!"].waitForExistence(timeout: 8))
  }

  func testMilitaryAllowsNegativeValues() {
    let app = XCUIApplication()
    startTwoPlayerGame(app)

    let minus = app.buttons["military.minus"]
    waitFor(minus, 10)

    // From 0, three decrements → −3 (military allows negatives).
    for _ in 0..<3 { minus.tap() }
    XCTAssertEqual(app.buttons["military.value"].label, "-3")
    XCTAssertEqual(app.staticTexts["scoring.total"].label, "-3 VP")
  }

  func testTreasuryClampsAtZero() {
    let app = XCUIApplication()
    startTwoPlayerGame(app)

    let minus = app.buttons["treasury.minus"]
    waitFor(minus, 10)

    // Treasury does not allow negatives — stays at 0.
    for _ in 0..<3 { minus.tap() }
    XCTAssertEqual(app.buttons["treasury.value"].label, "0")
  }

  func testKeypadNextScrollsEditedFieldIntoView() {
    let app = XCUIApplication()
    startTwoPlayerGame(app)

    // Open the keypad on Military, then Next down to a symbol field, which sits
    // far below (under the keypad). It must be scrolled into view to be hittable.
    app.buttons["military.value"].tap()
    let next = app.buttons["keypad.next"]
    waitFor(next, 10)
    for _ in 0..<6 { next.tap() }  // military → … → compass (first symbol)

    XCTAssertTrue(app.buttons["compass.value"].isHittable,
                  "Next should scroll the highlighted field into view")
  }
}
