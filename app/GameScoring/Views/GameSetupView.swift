import SwiftData
import SwiftUI

/// Full-screen setup cover: pick the players for a game, then start scoring.
/// Presented over the Shelf/Home; the tab bar is hidden while it's up.
struct GameSetupView: View {
  let game: any ScoringGame
  /// Players to pre-select (e.g. Results → Play again reuses the same table).
  var initialPlayerIDs: [UUID] = []

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context

  @Query(
    filter: #Predicate<Player> { $0.deletedAt == nil },
    sort: \Player.createdAt,
    order: .forward
  )
  private var roster: [Player]

  /// Ordered list of chosen player IDs — order is the seating order.
  @State private var selectedIDs: [UUID] = []
  @State private var removeMode = false
  @State private var showingAdd = false
  @State private var startedSession: GameSession?

  private var selectedPlayers: [Player] {
    selectedIDs.compactMap { id in roster.first { $0.id == id } }
  }

  private var availablePlayers: [Player] {
    roster.filter { !selectedIDs.contains($0.id) }
  }

  private var canAddMore: Bool { selectedIDs.count < game.maxPlayers }
  private var canStart: Bool { selectedIDs.count >= game.minPlayers }

  // No internal NavigationStack: callers embed this in their own stack so the
  // view works both as the cover root and when pushed (Results → Play again).
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        selectedCluster
        rosterSection
      }
      .padding(20)
    }
    .background(Theme.background)
    .navigationTitle(game.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { dismiss() }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Text("\(selectedIDs.count) / \(game.maxPlayers)")
          .font(.subheadline.monospacedDigit())
          .foregroundStyle(Theme.textSecondary)
      }
    }
    .safeAreaInset(edge: .bottom) { startBar }
    .sheet(isPresented: $showingAdd) {
      AddPlayerSheet { newPlayer in
        if canAddMore { selectedIDs.append(newPlayer.id) }
      }
    }
    .navigationDestination(item: $startedSession) { session in
      ScoringView(session: session)
    }
    .onAppear {
      // Pre-select requested players (e.g. Play again). Set directly rather than
      // filtering the @Query roster, which may not have loaded yet on first
      // appear; `selectedPlayers` already ignores any id no longer in the roster.
      if selectedIDs.isEmpty, !initialPlayerIDs.isEmpty {
        selectedIDs = initialPlayerIDs
      }
    }
  }

  // MARK: - Selected players

  private var selectedCluster: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Players")
        .font(.headline)
        .foregroundStyle(Theme.textPrimary)

      if selectedPlayers.isEmpty {
        Text("Add at least \(game.minPlayers) players to start.")
          .font(.subheadline)
          .foregroundStyle(Theme.textSecondary)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 8)
      }

      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 72), spacing: 16)],
        spacing: 16
      ) {
        ForEach(selectedPlayers) { player in
          bubble(for: player)
        }
        newBubble
      }
    }
  }

  private func bubble(for player: Player) -> some View {
    VStack(spacing: 6) {
      ZStack(alignment: .topTrailing) {
        PlayerAvatar(name: player.name, colorHex: player.avatarColor, size: 56)
        if removeMode {
          Image(systemName: "xmark.circle.fill")
            .font(.title3)
            .foregroundStyle(.white, Theme.accentDeep)
            .offset(x: 6, y: -6)
        }
      }
      Text(player.name)
        .font(.caption)
        .lineLimit(1)
        .foregroundStyle(Theme.textPrimary)
    }
    .frame(width: 72)
    .contentShape(.rect)
    .onTapGesture {
      if removeMode { deselect(player) }
    }
    .onLongPressGesture {
      withAnimation(.snappy) { removeMode.toggle() }
    }
  }

  private var newBubble: some View {
    VStack(spacing: 6) {
      Circle()
        .strokeBorder(Theme.accentPrimary, style: StrokeStyle(lineWidth: 2, dash: [5]))
        .frame(width: 56, height: 56)
        .overlay {
          Image(systemName: "plus")
            .font(.title3.weight(.semibold))
            .foregroundStyle(Theme.accentPrimary)
        }
      Text("New")
        .font(.caption)
        .foregroundStyle(Theme.accentPrimary)
    }
    .frame(width: 72)
    .contentShape(.rect)
    .onTapGesture { showingAdd = true }
    .opacity(canAddMore ? 1 : 0.35)
    .disabled(!canAddMore)
  }

  // MARK: - Roster

  private var rosterSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Add from roster")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Theme.textSecondary)

      if availablePlayers.isEmpty {
        Text(roster.isEmpty
          ? "No saved players yet — tap New to add one."
          : "Everyone's added. Tap New to create another player.")
          .font(.footnote)
          .foregroundStyle(Theme.textSecondary)
          .padding(.vertical, 4)
      }

      ForEach(availablePlayers) { player in
        Button {
          select(player)
        } label: {
          HStack(spacing: 12) {
            PlayerAvatar(name: player.name, colorHex: player.avatarColor, size: 36)
            Text(player.name)
              .foregroundStyle(Theme.textPrimary)
            Spacer()
            Image(systemName: "plus.circle.fill")
              .foregroundStyle(canAddMore ? Theme.accentPrimary : Theme.textSecondary)
          }
          .padding(12)
          .background(.regularMaterial, in: .rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(!canAddMore)
        .accessibilityIdentifier("roster.\(player.name)")
      }
    }
  }

  // MARK: - Start

  private var startBar: some View {
    Button(action: start) {
      Text("Start scoring  →")
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    .buttonStyle(.borderedProminent)
    .tint(Theme.accentPrimary)
    .disabled(!canStart)
    .padding(.horizontal, 20)
    .padding(.bottom, 8)
    .accessibilityIdentifier("setup.start")
  }

  // MARK: - Actions

  private func select(_ player: Player) {
    guard canAddMore, !selectedIDs.contains(player.id) else { return }
    selectedIDs.append(player.id)
  }

  private func deselect(_ player: Player) {
    selectedIDs.removeAll { $0 == player.id }
    if selectedIDs.isEmpty { removeMode = false }
  }

  /// Discards any existing in-progress session (only one is kept at a time),
  /// then creates the new session and its per-player score rows.
  private func start() {
    guard canStart else { return }
    startedSession = SessionService.start(
      game: game,
      players: selectedPlayers,
      in: context
    )
  }
}
