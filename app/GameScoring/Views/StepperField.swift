import SwiftUI

/// A `[ − ]  value  [ + ]` score control. − / + nudge by one; tapping the value
/// opens the in-app keypad (`ScoreKeypad`) for precise entry. Untouched zeros
/// show as grey placeholder; touched values (incl. 0) show solid; negatives red.
struct StepperField: View {
  let categoryID: String
  let value: Double
  let allowsNegative: Bool
  let touched: Bool
  /// True while this field is the one the keypad is editing.
  let isEditing: Bool
  /// Step by a delta (±1 from the buttons).
  let onStep: (_ delta: Double) -> Void
  /// Open the keypad for this field.
  let onTapValue: () -> Void

  private static let negativeColor = Color(hex: 0xdc2626)

  private var displayText: String {
    (!touched && value == 0) ? "0" : String(Int(value))
  }

  private var isPlaceholder: Bool { !touched && value == 0 }

  var body: some View {
    HStack(spacing: 10) {
      stepButton("minus") { onStep(-1) }
        .accessibilityIdentifier("\(categoryID).minus")

      Button(action: onTapValue) {
        Text(displayText)
          .font(.body.weight(.semibold).monospacedDigit())
          .foregroundStyle(valueColor)
          .frame(minWidth: 52)
          .padding(.vertical, 4)
          .background(
            isEditing ? Theme.accentPrimary.opacity(0.15) : Color.clear,
            in: .rect(cornerRadius: 8)
          )
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("\(categoryID).value")

      stepButton("plus") { onStep(1) }
        .accessibilityIdentifier("\(categoryID).plus")
    }
  }

  private var valueColor: Color {
    if value < 0 { return Self.negativeColor }
    return isPlaceholder ? Theme.textSecondary.opacity(0.5) : Theme.textPrimary
  }

  private func stepButton(_ symbol: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.body.weight(.semibold))
        .foregroundStyle(Theme.accentPrimary)
        .frame(width: 32, height: 32)
        .background(Theme.accentPrimary.opacity(0.12), in: .circle)
    }
    .buttonStyle(.plain)
  }
}
