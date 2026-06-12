import SwiftData
import SwiftUI

/// Modal sheet for creating a new roster player: a name field, a live avatar
/// preview, and the color picker. Inserts into the model context on Add.
struct AddPlayerSheet: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context

  /// Called with the freshly inserted player, e.g. so the setup flow can
  /// auto-select it. Nil for the plain roster-management use.
  var onCreate: ((Player) -> Void)? = nil

  @State private var name = ""
  @State private var color = Theme.avatarPalette[0]
  @FocusState private var nameFocused: Bool

  private var trimmedName: String {
    name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          HStack(spacing: 14) {
            PlayerAvatar(name: trimmedName, colorHex: color, size: 56)
            TextField("Player name", text: $name)
              .font(.title3)
              .focused($nameFocused)
              .submitLabel(.done)
              .onSubmit(addPlayer)
          }
          .padding(.vertical, 4)
          .listRowBackground(Color.clear)
        }

        Section("Color") {
          AvatarColorPicker(selection: $color)
            .listRowBackground(Color.clear)
        }
      }
      .scrollContentBackground(.hidden)
      .background(Theme.background)
      .navigationTitle("New Player")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Add", action: addPlayer)
            .disabled(trimmedName.isEmpty)
        }
      }
      .onAppear { nameFocused = true }
    }
  }

  private func addPlayer() {
    guard !trimmedName.isEmpty else { return }
    let player = Player(name: trimmedName, avatarColor: color)
    context.insert(player)
    onCreate?(player)
    dismiss()
  }
}
