import SwiftData
import SwiftUI

@main
struct GameScoringApp: App {
  let modelContainer: ModelContainer

  init() {
    let schema = Schema([Player.self, GameSession.self, PlayerScore.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
      modelContainer = try ModelContainer(for: schema, configurations: [config])
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
}
