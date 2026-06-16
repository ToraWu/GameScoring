import SwiftUI

/// A `[ − ]  value  [ + ]` score input. The value is tappable for direct keypad
/// entry; − / + adjust by one. Untouched zeros show as a grey placeholder;
/// touched values (including an explicit 0) show solid; negatives show red.
///
/// A local text buffer backs the field so partial entries survive — notably a
/// leading "-" while typing a negative number (which would otherwise be erased
/// because it parses to 0).
struct StepperField: View {
  let categoryID: String
  let value: Double
  let allowsNegative: Bool
  let touched: Bool
  /// Reports a new value and whether the field should be marked as touched.
  let onSet: (_ value: Double, _ markTouched: Bool) -> Void

  @FocusState.Binding var keyboardActive: Bool
  @State private var text: String = ""

  private static let negativeColor = Color(hex: 0xdc2626)

  private var display: String {
    (!touched && value == 0) ? "" : String(Int(value))
  }

  var body: some View {
    HStack(spacing: 10) {
      stepButton("minus") { commit(value - 1) }
        .accessibilityIdentifier("\(categoryID).minus")

      TextField("0", text: $text)
        .keyboardType(allowsNegative ? .numbersAndPunctuation : .numberPad)
        .multilineTextAlignment(.center)
        .font(.body.weight(.semibold).monospacedDigit())
        .foregroundStyle(value < 0 ? Self.negativeColor : Theme.textPrimary)
        .frame(width: 52)
        .focused($keyboardActive)
        .onChange(of: text) { _, new in handleTyping(new) }
        .accessibilityIdentifier("\(categoryID).value")

      stepButton("plus") { commit(value + 1) }
        .accessibilityIdentifier("\(categoryID).plus")
    }
    .onAppear { text = display }
    .onChange(of: value) { _, newValue in
      // Reflect external changes (stepper, player switch) but don't clobber an
      // in-progress entry that already equals the value (e.g. a lone "-" → 0).
      if parse(text) != newValue { text = display }
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

  private func handleTyping(_ new: String) {
    let sanitized = sanitize(new)
    if sanitized != new { text = sanitized }  // reformat in place
    onSet(parse(sanitized), true)
  }

  private func commit(_ newValue: Double) {
    let clamped = clamp(newValue)
    onSet(clamped, true)
    text = String(Int(clamped))
  }

  private func sanitize(_ raw: String) -> String {
    let digits = raw.filter(\.isNumber)
    let negative = allowsNegative && raw.hasPrefix("-")
    return (negative ? "-" : "") + digits
  }

  private func parse(_ raw: String) -> Double { Double(raw) ?? 0 }

  private func clamp(_ v: Double) -> Double {
    (!allowsNegative && v < 0) ? 0 : v
  }
}
