import XCTest

/// Verifies Ticket to Ride's negative-ticket penalty end-to-end through the UI.
final class TicketToRideUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  func testUncompletedTicketsReduceTotal() {
    let app = XCUIApplication()
    app.launchFresh(seedPlayers: true)

    app.tabBars.buttons["Shelf"].tap()
    let card = app.buttons["game.tickettoride"]
    waitFor(card)
    card.tap()
    app.buttons["roster.Ada"].tap()
    app.buttons["roster.Boris"].tap()
    app.buttons["setup.start"].tap()

    // Type values directly (faster than stepping).
    let routes = app.textFields["routes.value"]
    waitFor(routes, 10)
    routes.tap()
    routes.typeText("50")

    // Tickets allow negatives — a failed ticket subtracts.
    let tickets = app.textFields["tickets.value"]
    tickets.tap()
    tickets.typeText("-8")

    // 50 routes − 8 tickets = 42.
    XCTAssertEqual(app.staticTexts["scoring.total"].label, "42 VP")
  }
}
