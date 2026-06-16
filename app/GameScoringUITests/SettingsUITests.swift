import XCTest

/// Verifies the About sheet opens from the Shelf and shows version info.
final class SettingsUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  func testAboutSheetShowsVersionAndGames() {
    let app = XCUIApplication()
    app.launchFresh()

    app.tabBars.buttons["Shelf"].tap()
    let gear = app.buttons["shelf.settings"]
    waitFor(gear, 10)
    gear.tap()

    XCTAssertTrue(app.staticTexts["BoardScore"].waitForExistence(timeout: 8))
    XCTAssertTrue(app.staticTexts["Version"].exists)
    XCTAssertTrue(app.staticTexts["Build"].exists)
    XCTAssertTrue(app.staticTexts["Games"].exists)
    XCTAssertTrue(app.staticTexts["4"].exists)  // four games registered

    app.buttons["settings.done"].tap()
    XCTAssertFalse(app.staticTexts["Version"].exists)  // sheet dismissed
  }
}
