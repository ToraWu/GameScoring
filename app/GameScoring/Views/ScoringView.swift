import SwiftData
import SwiftUI

/// Score-entry screen for a session. One player at a time; the player strip and
/// running total are pinned and collapse as the form scrolls. Direct categories
/// use steppers (some allow negatives); computed categories update live.
struct ScoringView: View {
  let session: GameSession

  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  /// Raw inputs keyed by PlayerScore.id → category id → value.
  @State private var inputs: [UUID: [String: Double]] = [:]
  /// "scoreID|categoryID" keys the user has edited (controls placeholder vs solid 0).
  @State private var touched: Set<String> = []
  @State private var currentIndex = 0
  @State private var showDiscardAlert = false
  @State private var finishedSession: GameSession?
  @State private var collapse: CGFloat = 0
  /// Category currently being edited by the in-app keypad, if any.
  @State private var editingCategoryID: String?
  /// True when the next digit should replace (not append to) the value.
  @State private var keypadFresh = false

  private var game: (any ScoringGame)? { GameRegistry.game(for: session.gameID) }

  private var orderedScores: [PlayerScore] {
    session.playerScores.sorted {
      ($0.player?.createdAt ?? .distantPast) < ($1.player?.createdAt ?? .distantPast)
    }
  }

  private var currentScore: PlayerScore? {
    orderedScores.indices.contains(currentIndex) ? orderedScores[currentIndex] : nil
  }

  private var isLastPlayer: Bool { currentIndex >= orderedScores.count - 1 }

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
    .background(Theme.background.ignoresSafeArea())
    .navigationTitle(session.gameName)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Back") { showDiscardAlert = true }
          .accessibilityIdentifier("scoring.back")
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button("Finish") { finish() }
          .fontWeight(.semibold)
          .disabled(game == nil)
          .accessibilityIdentifier("scoring.finishNav")
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
    .safeAreaInset(edge: .bottom) { keypadDock }
    .onAppear(perform: loadInputs)
  }

  @ViewBuilder
  private var keypadDock: some View {
    if let categoryID = editingCategoryID,
       let category = game?.categories.first(where: { $0.id == categoryID }) {
      ScoreKeypad(
        categoryName: category.name,
        allowsNegative: category.allowsNegative,
        onDigit: { keypadDigit($0) },
        onDelete: keypadDelete,
        onClear: { setEditing(0) },
        onSign: keypadSign,
        onAdd: { keypadAdd($0) },
        onNext: keypadNext,
        onClose: { editingCategoryID = nil }
      )
      .transition(.move(edge: .bottom))
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

    VStack(spacing: 0) {
      header(score: score, total: computed.values.reduce(0, +))
      form(score: score, scoringCats: scoringCats, symbolCats: symbolCats, computed: computed)
    }
  }

  // MARK: - Pinned, collapsing header

  private func header(score: PlayerScore, total: Double) -> some View {
    let avatar = 52 - 18 * collapse
    let totalFont = 40 - 16 * collapse

    return VStack(spacing: 6) {
      playerStrip(currentAvatar: avatar)
      Text(score.player?.name ?? "Player")
        .font(.subheadline)
        .foregroundStyle(Theme.textSecondary)
        .opacity(1 - collapse)
        .frame(height: (1 - collapse) * 20)
      Text("\(formatted(total)) VP")
        .font(.system(size: totalFont, weight: .bold, design: .rounded))
        .foregroundStyle(Theme.accentPrimary)
        .contentTransition(.numericText())
        .animation(.snappy, value: total)
        .accessibilityIdentifier("scoring.total")
    }
    .padding(.top, 12)
    .padding(.bottom, 14 - 6 * collapse)
    .frame(maxWidth: .infinity)
    .background(Theme.background)
    .contentShape(.rect)
    .onTapGesture { editingCategoryID = nil }  // tap header to close keypad
  }

  private func playerStrip(currentAvatar: CGFloat) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(Array(orderedScores.enumerated()), id: \.element.id) { index, score in
          let isCurrent = index == currentIndex
          PlayerAvatar(
            name: score.player?.name ?? "?",
            colorHex: score.player?.avatarColor ?? "#888888",
            size: isCurrent ? currentAvatar : 34
          )
          .opacity(isCurrent ? 1 : 0.55)
          .overlay {
            if isCurrent {
              Circle().strokeBorder(Theme.accentPrimary, lineWidth: 2)
            }
          }
          .onTapGesture { switchTo(index) }
          .accessibilityIdentifier("scoring.player.\(index)")
        }
      }
      .padding(.horizontal, 20)
      .frame(minWidth: 0)
    }
  }

  // MARK: - Scrolling form

  private func form(
    score: PlayerScore,
    scoringCats: [ScoreCategory],
    symbolCats: [ScoreCategory],
    computed: [String: Double]
  ) -> some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(spacing: 16) {
          Color.clear.frame(height: 0).id("top")
          categoryCard(scoringCats, score: score, computed: computed)
          if !symbolCats.isEmpty {
            categoryCard(symbolCats, score: score, computed: computed, title: "Symbols")
          }
          navButtons
        }
        .padding(20)
      }
      .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, y in
        collapse = min(1, max(0, y / 56))
      }
      .onChange(of: currentIndex) { _, _ in
        withAnimation(.snappy) { proxy.scrollTo("top", anchor: .top) }
      }
    }
  }

  private func categoryCard(
    _ rows: [ScoreCategory],
    score: PlayerScore,
    computed: [String: Double],
    title: String? = nil
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
    HStack(spacing: 10) {
      Image(systemName: category.icon)
        .font(.body)
        .foregroundStyle(Color(hexString: category.colorHex))
        .frame(width: 26)
      Text(category.name)
        .foregroundStyle(Theme.textPrimary)
      Spacer()
      switch category.inputType {
      case .integer:
        StepperField(
          categoryID: category.id,
          value: inputs[score.id]?[category.id] ?? 0,
          allowsNegative: category.allowsNegative,
          touched: touched.contains(touchKey(score.id, category.id)),
          isEditing: editingCategoryID == category.id,
          onStep: { delta in step(score.id, category, by: delta) },
          onTapValue: { openKeypad(category.id) }
        )
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
        switchTo(currentIndex - 1)
      } label: {
        Label("Previous", systemImage: "chevron.left")
          .frame(maxWidth: .infinity).padding(.vertical, 12)
      }
      .buttonStyle(.bordered)
      .disabled(currentIndex == 0)
      .accessibilityIdentifier("scoring.previous")

      if isLastPlayer {
        Button { finish() } label: {
          Label("Finish", systemImage: "checkmark")
            .frame(maxWidth: .infinity).padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("scoring.finish")
      } else {
        Button { switchTo(currentIndex + 1) } label: {
          Label("Next", systemImage: "chevron.right")
            .frame(maxWidth: .infinity).padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("scoring.next")
      }
    }
    .tint(Theme.accentPrimary)
  }

  // MARK: - Input plumbing

  private func touchKey(_ scoreID: UUID, _ categoryID: String) -> String {
    "\(scoreID.uuidString)|\(categoryID)"
  }

  private func setInput(_ scoreID: UUID, _ categoryID: String, _ value: Double, _ mark: Bool) {
    inputs[scoreID, default: [:]][categoryID] = value
    if mark { touched.insert(touchKey(scoreID, categoryID)) }
    persistInputs()
  }

  private func checkboxBinding(_ scoreID: UUID, _ categoryID: String) -> Binding<Bool> {
    Binding(
      get: { (inputs[scoreID]?[categoryID] ?? 0) > 0 },
      set: { setInput(scoreID, categoryID, $0 ? 1 : 0, true) }
    )
  }

  private func formatted(_ value: Double) -> String {
    String(Int(value.rounded()))
  }

  // MARK: - Keypad

  private var editingValue: Double {
    guard let score = currentScore, let id = editingCategoryID else { return 0 }
    return inputs[score.id]?[id] ?? 0
  }

  private func openKeypad(_ categoryID: String) {
    editingCategoryID = categoryID
    keypadFresh = true  // first digit replaces the existing value
  }

  private func setEditing(_ value: Double) {
    guard let score = currentScore, let id = editingCategoryID else { return }
    setInput(score.id, id, value, true)
    keypadFresh = false
  }

  private func keypadDigit(_ digit: Int) {
    let current = editingValue
    let magnitude = abs(Int(current))
    let negative = current < 0
    let newMagnitude = keypadFresh ? digit : magnitude * 10 + digit
    setEditing(Double(negative ? -newMagnitude : newMagnitude))
  }

  private func keypadDelete() {
    let current = Int(editingValue)
    let newMagnitude = abs(current) / 10
    setEditing(Double(current < 0 ? -newMagnitude : newMagnitude))
  }

  private func keypadSign() {
    guard let category = game?.categories.first(where: { $0.id == editingCategoryID }),
          category.allowsNegative else { return }
    setEditing(-editingValue)
  }

  private func keypadAdd(_ delta: Double) {
    guard let category = game?.categories.first(where: { $0.id == editingCategoryID }) else { return }
    setEditing(clamp(editingValue + delta, allowsNegative: category.allowsNegative))
  }

  /// Advance the keypad to the next direct-input category, wrapping to the first.
  private func keypadNext() {
    guard let game, let current = editingCategoryID else { return }
    let inputOnly = ScoringEngine.inputOnlyIDs(for: game)
    let ids = game.categories
      .filter { if case .integer = $0.inputType { return true } else { return false } }
      .sorted { $0.displayOrder < $1.displayOrder }
      .map(\.id)
    // Order with scoring categories first, then symbols (matches the form layout).
    let ordered = ids.filter { !inputOnly.contains($0) } + ids.filter { inputOnly.contains($0) }
    guard let index = ordered.firstIndex(of: current), !ordered.isEmpty else { return }
    openKeypad(ordered[(index + 1) % ordered.count])
  }

  // MARK: - Actions

  private func step(_ scoreID: UUID, _ category: ScoreCategory, by delta: Double) {
    let current = inputs[scoreID]?[category.id] ?? 0
    setInput(scoreID, category.id, clamp(current + delta, allowsNegative: category.allowsNegative), true)
  }

  private func clamp(_ value: Double, allowsNegative: Bool) -> Double {
    (!allowsNegative && value < 0) ? 0 : value
  }

  private func switchTo(_ index: Int) {
    guard orderedScores.indices.contains(index) else { return }
    editingCategoryID = nil
    withAnimation(.snappy) { currentIndex = index }
  }

  private func finish() {
    guard let game else { return }
    persistInputs()
    SessionService.finish(session, game: game, inputs: inputs)
    finishedSession = session
  }

  private func discard() {
    context.delete(session)
    dismiss()
  }

  /// Restores raw inputs (resume or revise a finished game). Loaded values are
  /// marked touched so they render solid rather than as placeholders.
  private func loadInputs() {
    guard inputs.isEmpty else { return }
    for score in orderedScores {
      let raw = score.rawInputs
      guard !raw.isEmpty else { continue }
      inputs[score.id] = raw
      for key in raw.keys { touched.insert(touchKey(score.id, key)) }
    }
  }

  /// Persists raw inputs so progress survives backgrounding/relaunch; only
  /// writes players whose inputs changed.
  private func persistInputs() {
    for score in orderedScores {
      guard let raw = inputs[score.id], raw != score.rawInputs else { continue }
      score.rawInputs = raw
    }
  }
}
