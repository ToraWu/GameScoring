import XCTest

/// Sanity check that the app launches and the tab bar is present.
final class SmokeUITests: XCTestCase {
  override func setUp() { continueAfterFailure = false }

  func testLaunchesToHomeWithTabBar() {
    let app = XCUIApplication()
    app.launchFresh()

    XCTAssertTrue(app.staticTexts["BoardScore"].waitForExistence(timeout: 10))
    XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    XCTAssertTrue(app.tabBars.buttons["Shelf"].exists)
  }

  func testHomeShowsVersionFooter() {
    let app = XCUIApplication()
    app.launchFresh()

    let footer = app.staticTexts["home.version"]
    XCTAssertTrue(footer.waitForExistence(timeout: 10))
    XCTAssertTrue(footer.label.contains("BoardScore"), "footer was: \(footer.label)")
    XCTAssertTrue(footer.label.contains("build"), "footer was: \(footer.label)")
  }
}
