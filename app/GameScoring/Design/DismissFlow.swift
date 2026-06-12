import SwiftUI

/// Dismisses the whole score-entry flow (the setup full-screen cover), as
/// opposed to `dismiss()` which only pops one level. Injected by the presenter
/// (Shelf) and called from deep inside (Results' Done button).
struct DismissFlowAction {
  let action: () -> Void
  func callAsFunction() { action() }
}

private struct DismissFlowKey: EnvironmentKey {
  static let defaultValue = DismissFlowAction(action: {})
}

extension EnvironmentValues {
  var dismissFlow: DismissFlowAction {
    get { self[DismissFlowKey.self] }
    set { self[DismissFlowKey.self] = newValue }
  }
}
