import SwiftUI

/// A themed, bottom-docked numeric keypad that replaces the system keyboard for
/// score entry. Purely presentational — all edits are reported through closures
/// so `ScoringView` owns the value.
struct ScoreKeypad: View {
  let categoryName: String
  let allowsNegative: Bool

  let onDigit: (Int) -> Void
  let onDelete: () -> Void
  let onClear: () -> Void
  let onSign: () -> Void
  let onAdd: (Double) -> Void
  let onNext: () -> Void
  let onClose: () -> Void

  var body: some View {
    VStack(spacing: 10) {
      header
      chips
      digitGrid
      Button(action: onNext) {
        Text("Next  ›")
          .font(.headline)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
      }
      .buttonStyle(.borderedProminent)
      .tint(Theme.accentPrimary)
      .accessibilityIdentifier("keypad.next")
    }
    .padding(14)
    .background(.regularMaterial)
    .overlay(alignment: .top) {
      Rectangle().fill(Theme.textSecondary.opacity(0.15)).frame(height: 0.5)
    }
  }

  private var header: some View {
    HStack {
      Text(categoryName)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Theme.textPrimary)
      Spacer()
      Button("Clear", action: onClear)
        .font(.subheadline)
        .tint(Theme.accentPrimary)
        .accessibilityIdentifier("keypad.clear")
      Button(action: onClose) {
        Image(systemName: "chevron.down")
          .font(.headline)
          .foregroundStyle(Theme.textSecondary)
          .padding(.leading, 10)
      }
      .accessibilityIdentifier("keypad.done")
    }
  }

  private var chips: some View {
    HStack(spacing: 8) {
      ForEach([1.0, 5.0, 10.0], id: \.self) { amount in
        Button { onAdd(amount) } label: {
          Text("+\(Int(amount))")
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(Theme.accentPrimary)
        .accessibilityIdentifier("keypad.add\(Int(amount))")
      }
    }
  }

  private var digitGrid: some View {
    VStack(spacing: 8) {
      ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.first) { row in
        HStack(spacing: 8) {
          ForEach(row, id: \.self) { digit in
            key(label: "\(digit)") { onDigit(digit) }
              .accessibilityIdentifier("keypad.\(digit)")
          }
        }
      }
      HStack(spacing: 8) {
        key(symbol: "plus.forwardslash.minus", action: onSign, enabled: allowsNegative)
          .accessibilityIdentifier("keypad.sign")
        key(label: "0") { onDigit(0) }
          .accessibilityIdentifier("keypad.0")
        key(symbol: "delete.left", action: onDelete)
          .accessibilityIdentifier("keypad.delete")
      }
    }
  }

  private func key(label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(label)
        .font(.title3.weight(.medium))
        .frame(maxWidth: .infinity, minHeight: 44)
    }
    .buttonStyle(KeyStyle())
  }

  private func key(
    symbol: String,
    action: @escaping () -> Void,
    enabled: Bool = true
  ) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.title3)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
    .buttonStyle(KeyStyle())
    .disabled(!enabled)
    .opacity(enabled ? 1 : 0.3)
  }
}

/// Flat key surface that matches the Warm Table palette.
private struct KeyStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(Theme.textPrimary)
      .background(
        Theme.background.opacity(configuration.isPressed ? 0.5 : 1),
        in: .rect(cornerRadius: 12)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(Theme.textSecondary.opacity(0.12), lineWidth: 0.5)
      )
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
  }
}
