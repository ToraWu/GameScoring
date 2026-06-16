import Foundation

/// Ticket to Ride base game (USA) scoring.
///
/// Final scores are three direct totals: train-route points, destination
/// tickets, and the +10 longest-route bonus. Destination tickets can be
/// **negative** (uncompleted tickets subtract), so that category allows
/// negatives. Ties are broken by destination-ticket score.
struct TicketToRide: ScoringGame {
  static let shared = TicketToRide()
  private init() {}

  let id = "tickettoride"
  let name = "Ticket to Ride"
  let artworkName = "TicketToRide"
  let minPlayers = 2
  let maxPlayers = 5

  let categories: [ScoreCategory] = [
    ScoreCategory(id: "routes", name: "Train Routes", inputType: .integer, displayOrder: 0,
                  icon: "tram.fill", colorHex: "#2f6fb0"),
    ScoreCategory(id: "tickets", name: "Tickets", inputType: .integer, displayOrder: 1,
                  icon: "ticket.fill", colorHex: "#3a8f5a", allowsNegative: true),
    ScoreCategory(id: "longest", name: "Longest Route", inputType: .integer, displayOrder: 2,
                  icon: "arrow.left.and.right", colorHex: "#7e5aa8"),
  ]

  let tieBreaker: TieBreakerRule = .byCategory("tickets")

  /// No computed categories.
  func calculateScores(_ inputs: [String: Double]) -> [String: Double] { [:] }
}
