import SwiftUI

/// About / settings sheet, presented from the gear in the Shelf nav bar.
/// Currently informational; a natural home for future options.
struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss

  private let repoURL = URL(string: "https://github.com/ToraWu/GameScoring")!

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          appHeader
          infoCard
          Link(destination: repoURL) {
            Label("View source on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
              .font(.subheadline.weight(.medium))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
          }
          .buttonStyle(.bordered)
          .tint(Theme.accentPrimary)
        }
        .padding(20)
      }
      .background(Theme.background)
      .navigationTitle("About")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
            .accessibilityIdentifier("settings.done")
        }
      }
    }
  }

  private var appHeader: some View {
    VStack(spacing: 12) {
      Image(systemName: "crown.fill")
        .font(.system(size: 44))
        .foregroundStyle(Theme.accentDeep)
        .frame(width: 96, height: 96)
        .background(Theme.iconBackground, in: .rect(cornerRadius: 22))
        .overlay(
          RoundedRectangle(cornerRadius: 22)
            .strokeBorder(.white.opacity(0.5), lineWidth: 1)
        )
      Text("BoardScore")
        .font(.title2.bold())
        .foregroundStyle(Theme.textPrimary)
      Text("Score any board game")
        .font(.subheadline)
        .foregroundStyle(Theme.textSecondary)
    }
    .padding(.top, 8)
  }

  private var infoCard: some View {
    VStack(spacing: 0) {
      infoRow("Version", AppVersion.release)
      Divider().overlay(Theme.textSecondary.opacity(0.15))
      infoRow("Build", AppVersion.build)
      Divider().overlay(Theme.textSecondary.opacity(0.15))
      infoRow("Games", "\(GameRegistry.all.count)")
    }
    .padding(.horizontal, 14)
    .background(.regularMaterial, in: .rect(cornerRadius: 16))
  }

  private func infoRow(_ label: String, _ value: String) -> some View {
    HStack {
      Text(label)
        .foregroundStyle(Theme.textPrimary)
      Spacer()
      Text(value)
        .font(.body.monospacedDigit())
        .foregroundStyle(Theme.textSecondary)
    }
    .padding(.vertical, 13)
  }
}
