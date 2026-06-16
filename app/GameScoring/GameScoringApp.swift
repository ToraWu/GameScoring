import SwiftData
import SwiftUI

@main
struct GameScoringApp: App {
  let modelContainer: ModelContainer

  init() {
    let schema = Schema([Player.self, GameSession.self, PlayerScore.self])
    do {
      modelContainer = try GameScoringApp.makeContainer(schema: schema)
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(modelContainer)
  }

  /// Builds the app's store. Under UI testing (`-uitestClean`) it uses a fresh
  /// temp store so each run starts deterministically; `-uitestSeed` adds a
  /// known roster. Otherwise it uses the normal persistent store.
  private static func makeContainer(schema: Schema) throws -> ModelContainer {
    let args = ProcessInfo.processInfo.arguments
    guard args.contains("-uitestClean") else {
      return try ModelContainer(
        for: schema,
        configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)]
      )
    }

    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("uitest-\(UUID().uuidString).store")
    let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(url: url)])

    let needsRoster = args.contains("-uitestSeed") || args.contains("-uitestSeedInProgress")
    if needsRoster {
      let context = container.mainContext
      let base = Date()
      let players = ["Ada", "Boris", "Chen", "Dee"].enumerated().map { index, name -> Player in
        let player = Player(
          name: name,
          avatarColor: Theme.avatarPalette[index % Theme.avatarPalette.count],
          createdAt: base.addingTimeInterval(Double(index))
        )
        context.insert(player)
        return player
      }
      // Seed an in-progress 7 Wonders game so Home shows the resume banner.
      if args.contains("-uitestSeedInProgress") {
        SessionService.start(
          game: SevenWonders.shared,
          players: Array(players.prefix(3)),
          in: context
        )
      }
    }
    return container
  }
}
