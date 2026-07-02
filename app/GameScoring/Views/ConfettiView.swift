import SwiftUI

/// A one-shot confetti burst that rains colourful pieces from the top and fades
/// out. Drop it in an overlay; the parent controls how long it stays mounted.
/// Rendered in a single `Canvas` for performance.
struct ConfettiView: View {
  var duration: Double = 3.2

  private struct Piece {
    let xFraction: CGFloat
    let color: Color
    let size: CGFloat
    let delay: Double
    let drift: CGFloat      // horizontal drift, fraction of width per second
    let sway: CGFloat       // sway amplitude in points
    let swaySpeed: Double
    let spin: Double        // radians per second
    let aspect: CGFloat     // height factor for the little rectangle
  }

  private let pieces: [Piece]
  private let start = Date()

  private static let colors: [Color] = [
    Color(hexString: "#e11d48"), Color(hexString: "#ea580c"), Color(hexString: "#ca8a04"),
    Color(hexString: "#16a34a"), Color(hexString: "#0891b2"), Color(hexString: "#4f46e5"),
    Color(hexString: "#7c3aed"), Color(hexString: "#db2777"),
    Theme.accentSecondary, Theme.accentPrimary,
  ]

  init(count: Int = 110, duration: Double = 3.2) {
    self.duration = duration
    pieces = (0..<count).map { _ in
      Piece(
        xFraction: .random(in: 0...1),
        color: Self.colors.randomElement()!,
        size: .random(in: 7...13),
        delay: .random(in: 0...0.5),
        drift: .random(in: -0.12...0.12),
        sway: .random(in: 8...34),
        swaySpeed: .random(in: 1.5...3.5),
        spin: .random(in: -4...4),
        aspect: .random(in: 0.5...1.0)
      )
    }
  }

  var body: some View {
    TimelineView(.animation) { timeline in
      Canvas { context, size in
        let t = timeline.date.timeIntervalSince(start)
        for piece in pieces {
          let pt = t - piece.delay
          guard pt >= 0 else { continue }
          let progress = pt / duration
          guard progress <= 1 else { continue }

          let fall = CGFloat(progress)
          let y = -20 + (size.height + 80) * fall
          let x = size.width * piece.xFraction
            + size.width * piece.drift * CGFloat(pt)
            + sin(pt * piece.swaySpeed) * piece.sway
          let opacity = progress < 0.8 ? 1.0 : (1 - (progress - 0.8) / 0.2)

          context.drawLayer { layer in
            layer.opacity = opacity
            layer.translateBy(x: x, y: y)
            layer.rotate(by: .radians(piece.spin * pt))
            let rect = CGRect(
              x: -piece.size / 2, y: -piece.size * piece.aspect / 2,
              width: piece.size, height: piece.size * piece.aspect
            )
            layer.fill(Path(roundedRect: rect, cornerRadius: 1.5), with: .color(piece.color))
          }
        }
      }
    }
    .allowsHitTesting(false)
    .ignoresSafeArea()
  }
}
