import Foundation

/// Input type for a scoring category.
enum CategoryInputType: Equatable {
  /// A whole or fractional number entered directly by the user.
  case integer
  /// A value derived from other categories; the list names the source category IDs.
  case computed([String])
  /// A binary toggle stored as 1.0 (checked) or 0.0 (unchecked).
  case checkbox
}

/// How ties are broken when two players share the highest VP total.
enum TieBreakerRule {
  case none
  /// Compare a specific category score; higher wins.
  case byCategory(String)
  /// The app prompts the table to decide manually.
  case manual
}

/// One scoring row shown in the Scoring screen.
struct ScoreCategory: Identifiable {
  let id: String
  let name: String
  let inputType: CategoryInputType
  /// Order in which this row appears in the scoring sheet (ascending).
  let displayOrder: Int
}

/// Adopted by every supported board game. The protocol is the only coupling
/// between game-specific logic and the generic session/player model layer.
protocol ScoringGame {
  /// Stable, URL-safe identifier used in `GameSession.gameID`.
  var id: String { get }
  var name: String { get }
  /// Asset-catalog image name for this game's cover art.
  var artworkName: String { get }
  var minPlayers: Int { get }
  var maxPlayers: Int { get }
  var categories: [ScoreCategory] { get }
  var tieBreaker: TieBreakerRule { get }

  /// Given a flat map of **all** raw inputs (both direct and source categories),
  /// returns only the computed VP values keyed by computed-category ID.
  /// The caller merges these into `categoryScores` alongside the direct inputs.
  func calculateScores(_ inputs: [String: Double]) -> [String: Double]
}
