import SwiftUI

/// A `[ − ]  value  [ + ]` score input. The value is tappable for direct keypad
/// entry; − / + adjust by one. Untouched zeros show as a grey placeholder;
/// touched values (including an explicit 0) show solid; negatives show red.
struct StepperField: View {
  let categoryID: String
  let value: Double
  let allowsNegative: Bool
  let touched: Bool
  /// Reports a new value and whether the field should be marked as touched.
  let onSet: (_ value: Double, _ markTouched: Bool) -> Void

  @FocusState.Binding var keyboardActive: Bool

  private static let negativeColor = Color(hex: 0xdc2626)

  private var displayText: String {
    (!touched && value == 0) ? "" : String(Int(value))
  }

  private var textColor: Color {
    value < 0 ? Self.negativeColor : Theme.textPrimary
  }

  var body: some View {
    HStack(spacing: 10) {
      stepButton("minus") { set(value - 1) }
        .accessibilityIdentifier("\(categoryID).minus")

      TextField("0", text: textBinding)
        .keyboardType(allowsNegative ? .numbersAndPunctuation : .numberPad)
        .multilineTextAlignment(.center)
        .font(.body.weight(.semibold).monospacedDigit())
        .foregroundStyle(textColor)
        .frame(width: 52)
        .focused($keyboardActive)
        .accessibilityIdentifier("\(categoryID).value")

      stepButton("plus") { set(value + 1) }
        .accessibilityIdentifier("\(categoryID).plus")
    }
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

  private func set(_ newValue: Double) {
    onSet(clamp(newValue), true)
  }

  private func clamp(_ v: Double) -> Double {
    (!allowsNegative && v < 0) ? 0 : v
  }

  private var textBinding: Binding<String> {
    Binding(
      get: { displayText },
      set: { text in
        var filtered = text.filter { $0.isNumber || $0 == "-" }
        if !allowsNegative { filtered.removeAll { $0 == "-" } }
        // Keep only a single leading minus.
        if let first = filtered.first, first == "-" {
          filtered = "-" + filtered.dropFirst().filter(\.isNumber)
        }
        onSet(clamp(Double(filtered) ?? 0), true)
      }
    )
  }
}
