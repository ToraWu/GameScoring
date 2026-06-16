import XCTest

/// Shared helpers for driving BoardScore in UI tests.
extension XCUIApplication {
  /// Launches with a fresh, empty on-disk store. Pass `seedPlayers` to also
  /// insert a known roster (Ada, Boris, Chen, Dee) for scoring flows.
  func launchFresh(seedPlayers: Bool = false) {
    launchArguments += ["-uitestClean"]
    if seedPlayers { launchArguments += ["-uitestSeed"] }
    launch()
  }
}

extension XCTestCase {
  /// Fails the test if `element` doesn't appear within `timeout` seconds.
  @discardableResult
  func waitFor(
    _ element: XCUIElement,
    timeout: TimeInterval = 8,
    _ message: String = "element did not appear"
  ) -> Bool {
    let ok = element.waitForExistence(timeout: timeout)
    XCTAssertTrue(ok, message)
    return ok
  }
}
