import XCTest

/// Shared helpers for driving BoardScore in UI tests.
extension XCUIApplication {
  /// Launches with a fresh, empty on-disk store. Pass `seedPlayers` to also
  /// insert a known roster (Ada, Boris, Chen, Dee); pass `inProgressGame` to
  /// additionally seed an in-progress 7 Wonders session (for the resume flow).
  func launchFresh(seedPlayers: Bool = false, inProgressGame: Bool = false) {
    launchArguments += ["-uitestClean"]
    if seedPlayers { launchArguments += ["-uitestSeed"] }
    if inProgressGame { launchArguments += ["-uitestSeedInProgress"] }
    launch()
  }
}

extension XCTestCase {
  /// Fails the test if `element` doesn't appear within `timeout` seconds.
  @discardableResult
  func waitFor(
    _ element: XCUIElement,
    _ timeout: TimeInterval = 8,
    _ message: String = "element did not appear"
  ) -> Bool {
    let ok = element.waitForExistence(timeout: timeout)
    XCTAssertTrue(ok, message)
    return ok
  }
}
