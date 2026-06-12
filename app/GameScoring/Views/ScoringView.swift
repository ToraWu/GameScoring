import SwiftData
import SwiftUI

/// Score-entry screen for an in-progress session. Shows one player at a time;
/// direct categories are editable, computed categories (e.g. 7 Wonders science)
/// update live. Back discards the session; Finish ranks and completes it.
struct ScoringView: View {
  let session: GameSession

  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  /// Raw inputs keyed by PlayerScore.id → category id → value.
  @State private var inputs: [UUID: [String: Double]] = [:]
  @State private var currentIndex = 0
  @State private var showDiscardAlert = false
  @State private var finishedSession: GameSession?

  private var game: (any ScoringGame)? { GameRegistry.game(for: session.gameID) }

  /// Stable player order (by roster creation time).
  private var orderedScores: [PlayerScore] {
    session.playerScores.sorted {
      ($0.player?.createdAt ?? .distantPast) < ($1.player?.createdAt ?? .distantPast)
    }
  }

  private var currentScore: PlayerScore? {
    orderedScores.indices.contains(currentIndex) ? orderedScores[currentIndex] : nil
  }

  var body: some View {
    Group {
      if let game, let score = currentScore {
        content(game: game, score: score)
      } else {
        PlaceholderView(
          systemImage: "exclamationmark.triangle",
          title: "Unavailable",
          subtitle: "This game could not be loaded."
        )
      }
    }
    .background(Theme.background)
    .navigationTitle(session.gameName)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Back") { showDiscardAlert = true }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button("Finish") { finish() }
          .fontWeight(.semibold)
          .disabled(game == nil)
      }
    }
    .alert("Discard scores?", isPresented: $showDiscardAlert) {
      Button("Discard", role: .destructive) { discard() }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Your entered scores will be lost and this game removed.")
    }
    .navigationDestination(item: $finishedSession) { session in
      ResultsView(session: session)
    }
  }

  // MARK: - Content

  @ViewBuilder
  private func content(game: any ScoringGame, score: PlayerScore) -> some View {
    let raw = inputs[score.id] ?? [:]
    let computed = ScoringEngine.categoryScores(for: game, inputs: raw)
    let inputOnly = ScoringEngine.inputOnlyIDs(for: game)
    let scoringCats = game.categories
      .filter { !inputOnly.contains($0.id) }
      .sorted { $0.displayOrder < $1.displayOrder }
    let symbolCats = game.categories
      .filter { inputOnly.contains($0.id) }
      .sorted { $0.displayOrder < $1.displayOrder }

    ScrollView {
      VStack(spacing: 20) {
        playerStrip
        totalCard(total: computed.values.reduce(0, +), name: score.player?.name ?? "Player")

        categorySection(rows: scoringCats, score: score, computed: computed)

        if !symbolCats.isEmpty {
          categorySection(title: "Symbols", rows: symbolCats, score: score, computed: computed)
        }

        navButtons
      }
      .padding(20)
    }
  }

  private var playerStrip: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(Array(orderedScores.enumerated()), id: \.element.id) { index, score in
          let isCurrent = index == currentIndex
          VStack(spacing: 4) {
            PlayerAvatar(
              name: score.player?.name ?? "?",
              colorHex: score.player?.avatarColor ?? "#888888",
              size: isCurrent ? 52 : 40
            )
            Text(score.player?.name ?? "?")
              .font(.caption2)
              .lineLimit(1)
              .foregroundStyle(isCurrent ? Theme.textPrimary : Theme.textSecondary)
          }
          .frame(width: 64)
          .opacity(isCurrent ? 1 : 0.6)
          .onTapGesture { withAnimation(.snappy) { currentIndex = index } }
        }
      }
      .padding(.horizontal, 4)
    }
  }

  private func totalCard(total: Double, name: String) -> some View {
    VStack(spacing: 2) {
      Text(name)
        .font(.subheadline)
        .foregroundStyle(Theme.textSecondary)
      Text("\(formatted(total)) VP")
        .font(.system(size: 40, weight: .bold, design: .rounded))
        .foregroundStyle(Theme.accentPrimary)
        .contentTransition(.numericText())
        .animation(.snappy, value: total)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(.regularMaterial, in: .rect(cornerRadius: 20))
  }

  private func categorySection(
    title: String? = nil,
    rows: [ScoreCategory],
    score: PlayerScore,
    computed: [String: Double]
  ) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      if let title {
        Text(title)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(Theme.textSecondary)
          .padding(.bottom, 8)
      }
      VStack(spacing: 0) {
        ForEach(rows) { category in
          categoryRow(category, score: score, computed: computed)
          if category.id != rows.last?.id {
            Divider().overlay(Theme.textSecondary.opacity(0.15))
          }
        }
      }
      .padding(.horizontal, 14)
      .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
  }

  @ViewBuilder
  private func categoryRow(
    _ category: ScoreCategory,
    score: PlayerScore,
    computed: [String: Double]
  ) -> some View {
    HStack {
      Text(category.name)
        .foregroundStyle(Theme.textPrimary)
      Spacer()
      switch category.inputType {
      case .integer:
        TextField("0", text: intBinding(score.id, category.id))
          .keyboardType(.numberPad)
          .multilineTextAlignment(.trailing)
          .frame(width: 80)
          .textFieldStyle(.roundedBorder)
      case .computed:
        Text("\(formatted(computed[category.id] ?? 0)) VP")
          .font(.body.weight(.semibold))
          .foregroundStyle(Theme.accentPrimary)
      case .checkbox:
        Toggle("", isOn: checkboxBinding(score.id, category.id))
          .labelsHidden()
      }
    }
    .padding(.vertical, 12)
  }

  private var navButtons: some View {
    HStack(spacing: 12) {
      Button {
        withAnimation(.snappy) { currentIndex -= 1 }
      } label: {
        Label("Previous", systemImage: "chevron.left")
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
      }
      .buttonStyle(.bordered)
      .disabled(currentIndex == 0)

      Button {
        withAnimation(.snappy) { currentIndex += 1 }
      } label: {
        Label("Next", systemImage: "chevron.right")
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
      }
      .buttonStyle(.bordered)
      .disabled(currentIndex >= orderedScores.count - 1)
    }
    .tint(Theme.accentPrimary)
  }

  // MARK: - Bindings & helpers

  private func intBinding(_ scoreID: UUID, _ categoryID: String) -> Binding<String> {
    Binding(
      get: {
        let value = inputs[scoreID]?[categoryID] ?? 0
        return value == 0 ? "" : String(Int(value))
      },
      set: { text in
        let digits = text.filter(\.isNumber)
        inputs[scoreID, default: [:]][categoryID] = Double(digits) ?? 0
      }
    )
  }

  private func checkboxBinding(_ scoreID: UUID, _ categoryID: String) -> Binding<Bool> {
    Binding(
      get: { (inputs[scoreID]?[categoryID] ?? 0) > 0 },
      set: { inputs[scoreID, default: [:]][categoryID] = $0 ? 1 : 0 }
    )
  }

  private func formatted(_ value: Double) -> String {
    String(Int(value.rounded()))
  }

  // MARK: - Actions

  private func finish() {
    guard let game else { return }
    SessionService.finish(session, game: game, inputs: inputs)
    finishedSession = session
  }

  private func discard() {
    context.delete(session)
    dismiss()
  }
}
