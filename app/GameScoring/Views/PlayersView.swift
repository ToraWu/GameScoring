import SwiftData
import SwiftUI

/// Players tab — the roster of reusable player profiles. Lists active players
/// oldest-first, supports inline name editing, swipe-to-remove (soft delete),
/// and adding via a sheet.
struct PlayersView: View {
  // Only active (non-soft-deleted) players, oldest first.
  @Query(
    filter: #Predicate<Player> { $0.deletedAt == nil },
    sort: \Player.createdAt,
    order: .forward
  )
  private var players: [Player]

  @State private var showingAdd = false

  var body: some View {
    NavigationStack {
      Group {
        if players.isEmpty {
          PlaceholderView(
            systemImage: "person.2",
            title: "No Players Yet",
            subtitle: "Add players to your roster to use them across games."
          )
        } else {
          rosterList
        }
      }
      .background(Theme.background)
      .navigationTitle("Players")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Add Player", systemImage: "plus") { showingAdd = true }
        }
      }
      .sheet(isPresented: $showingAdd) {
        AddPlayerSheet()
      }
    }
  }

  private var rosterList: some View {
    List {
      ForEach(players) { player in
        PlayerRow(player: player)
          .listRowBackground(Color.clear)
      }
      .onDelete(perform: remove)
    }
    .scrollContentBackground(.hidden)
  }

  /// Soft-delete so the player's name survives in past game history.
  private func remove(at offsets: IndexSet) {
    for index in offsets {
      players[index].softDelete()
    }
  }
}

/// One roster row: avatar plus an inline-editable name field.
private struct PlayerRow: View {
  @Bindable var player: Player

  var body: some View {
    HStack(spacing: 14) {
      PlayerAvatar(name: player.name, colorHex: player.avatarColor)
      TextField("Name", text: $player.name)
        .font(.body)
        .foregroundStyle(Theme.textPrimary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  PlayersView()
    .modelContainer(for: Player.self, inMemory: true)
}
