import SwiftData
import SwiftUI

/// Home tab — resume an in-progress game, start the most-played game, or pick
/// another. The launch point for the whole score-entry flow.
struct HomeView: View {
  @Query(filter: #Predicate<GameSession> { $0.completedAt == nil })
  private var inProgressSessions: [GameSession]

  @Query(filter: #Predicate<GameSession> { $0.completedAt != nil })
  private var completedSessions: [GameSession]

  @State private var flow: HomeFlow?

  private var resumable: GameSession? { inProgressSessions.first }

  private var featured: (any ScoringGame)? {
    if let id = HistoryStats.mostPlayedGameID(completedSessions),
       let game = GameRegistry.game(for: id) {
      return game
    }
    return GameRegistry.all.first
  }

  private var otherGames: [any ScoringGame] {
    GameRegistry.all.filter { $0.id != featured?.id }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          if let resumable {
            resumeBanner(for: resumable)
          }
          if let featured {
            featuredSection(featured)
          }
          if !otherGames.isEmpty {
            otherGamesSection
          }
        }
        .padding(20)
      }
      .background(Theme.background)
      .navigationTitle("BoardScore")
    }
    .fullScreenCover(item: $flow) { flow in
      switch flow {
      case .setup(let ref):
        GameSetupView(game: ref.game)
          .environment(\.dismissFlow, DismissFlowAction { self.flow = nil })
      case .resume(let session):
        NavigationStack { ScoringView(session: session) }
          .environment(\.dismissFlow, DismissFlowAction { self.flow = nil })
      }
    }
  }

  // MARK: - Resume

  private func resumeBanner(for session: GameSession) -> some View {
    Button {
      flow = .resume(session)
    } label: {
      HStack(spacing: 14) {
        Image(systemName: "play.circle.fill")
          .font(.system(size: 36))
          .foregroundStyle(Theme.accentPrimary)
        VStack(alignment: .leading, spacing: 2) {
          Text("Resume game")
            .font(.headline)
            .foregroundStyle(Theme.textPrimary)
          Text("\(session.gameName) · \(session.playerScores.count) players")
            .font(.subheadline)
            .foregroundStyle(Theme.textSecondary)
        }
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundStyle(Theme.textSecondary)
      }
      .padding(16)
      .background(.regularMaterial, in: .rect(cornerRadius: 20))
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .strokeBorder(Theme.accentPrimary.opacity(0.5), lineWidth: 1.5)
      )
    }
    .buttonStyle(.plain)
  }

  // MARK: - Featured

  private func featuredSection(_ game: any ScoringGame) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader(completedSessions.isEmpty ? "Start playing" : "Most played")
      Button {
        flow = .setup(GameRef(game: game))
      } label: {
        VStack(spacing: 0) {
          GameCard(game: game)
          Button {
            flow = .setup(GameRef(game: game))
          } label: {
            Text("Start a game  →")
              .font(.headline)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
          }
          .buttonStyle(.borderedProminent)
          .tint(Theme.accentPrimary)
          .allowsHitTesting(false)  // outer button handles the tap
          .padding(.top, 12)
        }
      }
      .buttonStyle(.plain)
    }
  }

  // MARK: - Other games

  private var otherGamesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("More games")
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 14) {
          ForEach(otherGames, id: \.id) { game in
            Button {
              flow = .setup(GameRef(game: game))
            } label: {
              GameCard(game: game)
                .frame(width: 260)
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }

  private func sectionHeader(_ title: String) -> some View {
    Text(title)
      .font(.title3.weight(.semibold))
      .foregroundStyle(Theme.textPrimary)
  }
}

/// What the Home full-screen cover is presenting.
private enum HomeFlow: Identifiable {
  case setup(GameRef)
  case resume(GameSession)

  var id: String {
    switch self {
    case .setup(let ref): "setup-\(ref.id)"
    case .resume(let session): "resume-\(session.id.uuidString)"
    }
  }
}
