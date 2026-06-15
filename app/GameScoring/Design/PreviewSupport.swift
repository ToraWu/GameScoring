#if DEBUG
import Foundation
import SwiftData

extension ModelContainer {
  /// Seeded container for SwiftUI previews. Uses an on-disk temp store because
  /// in-memory stores reject `@Attribute(.unique)` (same constraint the tests
  /// hit). Seeds a small roster so `@Query`-backed views render with content.
  @MainActor static let preview: ModelContainer = {
    let schema = Schema([Player.self, GameSession.self, PlayerScore.self])
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("preview-\(UUID().uuidString).store")
    let container = try! ModelContainer(
      for: schema,
      configurations: [ModelConfiguration(url: url)]
    )

    let context = container.mainContext
    for (index, name) in ["Ada", "Boris", "Chen"].enumerated() {
      context.insert(Player(
        name: name,
        avatarColor: Theme.avatarPalette[index % Theme.avatarPalette.count]
      ))
    }
    return container
  }()
}
#endif
