import SwiftUI

/// Shelf tab — the catalog of supported games; entry point for starting a game.
/// Tapping a card opens the setup flow as a full-screen cover.
struct ShelfView: View {
  private let games = GameRegistry.all
  @State private var setupGame: GameRef?
  @State private var showingSettings = false

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 16) {
          ForEach(games, id: \.id) { game in
            Button {
              setupGame = GameRef(game: game)
            } label: {
              GameCard(game: game)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("game.\(game.id)")
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
      }
      .background(Theme.background)
      .navigationTitle("Shelf")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("About", systemImage: "gearshape") { showingSettings = true }
            .accessibilityIdentifier("shelf.settings")
        }
      }
      .sheet(isPresented: $showingSettings) {
        SettingsView()
      }
    }
    .fullScreenCover(item: $setupGame) { wrapper in
      NavigationStack {
        GameSetupView(game: wrapper.game)
      }
      .environment(\.dismissFlow, DismissFlowAction { setupGame = nil })
    }
  }
}

/// A single game's cover card: artwork fills the card with a frosted-glass
/// caption (title + player count) floating over its lower edge, so the art
/// stays visible behind it.
struct GameCard: View {
  let game: any ScoringGame

  var body: some View {
    Image(game.artworkName)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(height: 170)
      .frame(maxWidth: .infinity)
      .overlay(alignment: .bottom) {
        VStack(alignment: .leading, spacing: 2) {
          Text(game.name)
            .font(.headline)
            .foregroundStyle(Theme.textPrimary)
          Text("\(game.minPlayers)–\(game.maxPlayers) players")
            .font(.subheadline)
            .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial)  // blurred glass over the artwork
      }
      .clipShape(.rect(cornerRadius: 20))
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .strokeBorder(.white.opacity(0.5), lineWidth: 1)  // specular rim
      )
  }
}

#Preview {
  ShelfView()
}
