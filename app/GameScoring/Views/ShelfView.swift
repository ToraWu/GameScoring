import SwiftUI

/// Shelf tab — the catalog of supported games; entry point for starting a game.
/// Tapping a card opens the setup flow as a full-screen cover.
struct ShelfView: View {
  private let games = GameRegistry.all
  @State private var setupGame: SetupGame?

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 16) {
          ForEach(games, id: \.id) { game in
            Button {
              setupGame = SetupGame(game: game)
            } label: {
              GameCard(game: game)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
      }
      .background(Theme.background)
      .navigationTitle("Shelf")
    }
    .fullScreenCover(item: $setupGame) { wrapper in
      GameSetupView(game: wrapper.game)
        .environment(\.dismissFlow, DismissFlowAction { setupGame = nil })
    }
  }
}

/// Identifiable wrapper so a chosen game can drive `fullScreenCover(item:)`.
private struct SetupGame: Identifiable {
  let game: any ScoringGame
  var id: String { game.id }
}

/// A single game's cover card: full-width artwork with a title/player-count
/// caption bar underneath, wrapped in a Liquid Glass surface.
private struct GameCard: View {
  let game: any ScoringGame

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Image(game.artworkName)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .clipped()

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
    }
    .background(.regularMaterial, in: .rect(cornerRadius: 20))
    .clipShape(.rect(cornerRadius: 20))
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(.white.opacity(0.5), lineWidth: 1)  // specular top rim
    )
  }
}

#Preview {
  ShelfView()
}
