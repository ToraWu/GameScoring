import Foundation

/// 7 Wonders base game scoring (no expansions).
///
/// VP categories and their order match the official score pad:
///   Military, Treasury, Wonders, Civilian, Science, Commerce, Guilds
///
/// Science is the only computed category: the player enters raw science
/// symbol counts (Compass, Tablet, Gear, Wildcard), and the app derives VP
/// using the standard formula (sets × 7 + sum of squares).
struct SevenWonders: ScoringGame {
  static let shared = SevenWonders()
  private init() {}

  let id = "7wonders"
  let name = "7 Wonders"
  let artworkName = "SevenWonders"
  let minPlayers = 2  // per PRD; covers the 2-player Free City variant
  let maxPlayers = 7

  let categories: [ScoreCategory] = [
    ScoreCategory(id: "military",  name: "Military",  inputType: .integer,                      displayOrder: 0),
    ScoreCategory(id: "treasury",  name: "Treasury",  inputType: .integer,                      displayOrder: 1),
    ScoreCategory(id: "wonders",   name: "Wonders",   inputType: .integer,                      displayOrder: 2),
    ScoreCategory(id: "civilian",  name: "Civilian",  inputType: .integer,                      displayOrder: 3),
    ScoreCategory(id: "science",   name: "Science",   inputType: .computed(["compass","tablet","gear","sci_wild"]), displayOrder: 4),
    ScoreCategory(id: "commerce",  name: "Commerce",  inputType: .integer,                      displayOrder: 5),
    ScoreCategory(id: "guilds",    name: "Guilds",    inputType: .integer,                      displayOrder: 6),

    // Science symbol inputs — shown as sub-rows under Science.
    ScoreCategory(id: "compass",   name: "Compass",   inputType: .integer,                      displayOrder: 40),
    ScoreCategory(id: "tablet",    name: "Tablet",    inputType: .integer,                      displayOrder: 41),
    ScoreCategory(id: "gear",      name: "Gear",      inputType: .integer,                      displayOrder: 42),
    ScoreCategory(id: "sci_wild",  name: "Wildcard",  inputType: .integer,                      displayOrder: 43),
  ]

  let tieBreaker: TieBreakerRule = .byCategory("treasury")

  func calculateScores(_ inputs: [String: Double]) -> [String: Double] {
    let compass  = Int(inputs["compass"]  ?? 0)
    let tablet   = Int(inputs["tablet"]   ?? 0)
    let gear     = Int(inputs["gear"]     ?? 0)
    let wildcard = Int(inputs["sci_wild"] ?? 0)

    let scienceVP = sciencePoints(compass: compass, tablet: tablet, gear: gear, wildcard: wildcard)
    return ["science": Double(scienceVP)]
  }

  // MARK: - Private

  private func sciencePoints(compass: Int, tablet: Int, gear: Int, wildcard: Int) -> Int {
    // Distribute wildcards to maximise VP using exhaustive search over small counts.
    var best = 0
    for extraCompass in 0...wildcard {
      for extraTablet in 0...(wildcard - extraCompass) {
        let extraGear = wildcard - extraCompass - extraTablet
        let vp = rawScienceVP(
          compass: compass + extraCompass,
          tablet:  tablet  + extraTablet,
          gear:    gear    + extraGear
        )
        if vp > best { best = vp }
      }
    }
    return best
  }

  private func rawScienceVP(compass: Int, tablet: Int, gear: Int) -> Int {
    let sets = min(compass, tablet, gear)
    return sets * 7 + compass * compass + tablet * tablet + gear * gear
  }
}
