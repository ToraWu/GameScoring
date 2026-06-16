import XCTest

/// Verifies Ticket to Ride's negative-ticket penalty and the in-app keypad.
final class TicketToRideUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  private func startGame(_ app: XCUIApplication) {
    app.launchFresh(seedPlayers: true)
    app.tabBars.buttons["Shelf"].tap()
    let card = app.buttons["game.tickettoride"]
    waitFor(card)
    card.tap()
    app.buttons["roster.Ada"].tap()
    app.buttons["roster.Boris"].tap()
    app.buttons["setup.start"].tap()
    waitFor(app.buttons["routes.value"], 10)
  }

  func testKeypadEntersLargeNumberAndChip() {
    let app = XCUIApplication()
    startGame(app)

    // Tap the value to open the keypad, type 47, then +10 chip → 57.
    app.buttons["routes.value"].tap()
    waitFor(app.buttons["keypad.4"], 8)
    app.buttons["keypad.4"].tap()
    app.buttons["keypad.7"].tap()
    app.buttons["keypad.add10"].tap()

    XCTAssertEqual(app.staticTexts["scoring.total"].label, "57 VP")
  }

  func testUncompletedTicketsReduceTotal() {
    let app = XCUIApplication()
    startGame(app)

    // Routes = 50.
    app.buttons["routes.value"].tap()
    waitFor(app.buttons["keypad.5"], 8)
    app.buttons["keypad.5"].tap()
    app.buttons["keypad.0"].tap()

    // Tickets = −8 (type 8, then ± to negate).
    app.buttons["tickets.value"].tap()
    app.buttons["keypad.8"].tap()
    app.buttons["keypad.sign"].tap()

    // 50 routes − 8 tickets = 42.
    XCTAssertEqual(app.staticTexts["scoring.total"].label, "42 VP")
  }
}
