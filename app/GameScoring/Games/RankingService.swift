import Foundation

/// Ranks players by score and determines the winners, applying the game's
/// tiebreaker rule. Uses competition ranking: two players who can't be
/// separated share a rank, and the next rank skips accordingly (1, 1, 3).
enum RankingService {
  /// One player's scoring summary going into ranking.
  struct Entry {
    let playerID: UUID
    let total: Double
    let categoryScores: [String: Double]
  }

  struct Result {
    /// Rank per player ID (1 = best).
    let ranks: [UUID: Int]
    /// All players sharing the top rank — one ID for a solo win, several for a tie.
    let winnerIDs: [UUID]
  }

  static func rank(game: any ScoringGame, entries: [Entry]) -> Result {
    // Comparison key: total first, then the tiebreaker category (higher wins).
    func key(_ entry: Entry) -> (Double, Double) {
      let tiebreak: Double
      switch game.tieBreaker {
      case .byCategory(let categoryID):
        tiebreak = entry.categoryScores[categoryID] ?? 0
      case .none, .manual:
        tiebreak = 0
      }
      return (entry.total, tiebreak)
    }

    func isBetter(_ a: (Double, Double), than b: (Double, Double)) -> Bool {
      a.0 != b.0 ? a.0 > b.0 : a.1 > b.1
    }

    var ranks: [UUID: Int] = [:]
    for entry in entries {
      let k = key(entry)
      // Competition rank = 1 + number of players strictly better.
      let better = entries.filter { isBetter(key($0), than: k) }.count
      ranks[entry.playerID] = better + 1
    }

    let winnerIDs = entries.filter { ranks[$0.playerID] == 1 }.map(\.playerID)
    return Result(ranks: ranks, winnerIDs: winnerIDs)
  }
}
