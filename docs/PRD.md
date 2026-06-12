# BoardScore — Product Requirements Document
**Version:** 2.1  
**Stack:** iOS 26 · SwiftUI · SwiftData · Liquid Glass  
**Updated:** June 2026

---

## Problem

End-of-game scoring in complex board games is slow and error-prone. Players want fast guided entry, a persistent record of past games tied to real player profiles, and a foundation for stats and leaderboards.

---

## Goals

- **Primary:** Score any supported board game faster than pen and paper.
- **Player profiles:** A global player roster persists across sessions. When starting a game, the scorer picks from existing profiles or creates new ones inline.
- **Game history:** Every completed game is stored with scores linked to player profiles — the data foundation for leaderboards and per-player statistics.
- **Extensibility:** Game scoring logic is modular. Adding a new game must not require changes to core app structure, history, or player systems.

### Out of scope (v1)
Android, cloud sync, online accounts, leaderboard UI, stats UI, camera/voice input.

---

## Users

Board game players tracking scores at the table, typically 2–7 people, playing offline. One person operates the phone on behalf of the group.

---

## Core User Flows

### 1. Player setup
- App maintains a persistent roster of named player profiles (name + avatar colour)
- Profiles are created once and reused across any game
- Profiles can be created inline when starting a game, not just in a settings screen

### 2. Start a game
- Choose a game (7 Wonders and Wingspan in v1; base game only, no expansions)
- Add players from roster or create new ones — player count range enforced per game (e.g. 2–7 for 7 Wonders, 1–5 for Wingspan)
- Proceed to scoring

### 3. Score entry
- Guided per-category input for each player
- Scientific green card symbols entered as counts; app calculates VP automatically
- Running totals visible while entering

### 4. Results + history
- Winner declared, full score breakdown shown per player per category
- Game session saved automatically to local history
- History list is game-agnostic (shows all games, filterable by game type)

---

## Visual Style

**Chosen style: Warm Table**

| Token | Value |
|-------|-------|
| Background | `#faf5ed` (warm cream) |
| Surface (glass card) | `rgba(255,255,255,0.68)` + `border-top: 1px solid rgba(255,255,255,0.92)` |
| Accent primary | `#b45309` (amber) |
| Accent secondary | `#d97706` (gold) |
| Accent deep | `#92400e` (mahogany) |
| Text primary | `#1c1008` |
| Text secondary | `rgba(50,20,0,0.65)` |
| App icon background | `#f7ece0` (warm frosted glass, squircle 20 pt radius) |
| App icon glyph | `ti-crown`, `#92400e` |
| Tab bar | Floating glass pill — `rgba(255,255,255,0.65)` + bright specular top rim |
| Active tab icon | `#b45309` |
| Inactive tab icon | `rgba(50,20,0,0.22)` |

Liquid Glass surface treatment: semi-transparent fill + `border-top: 1px solid rgba(255,255,255,0.9)` specular highlight on all floating/card surfaces. No gradients. No drop shadows.

**Avatar colour palette (8 swatches):**
`#e11d48` · `#ea580c` · `#ca8a04` · `#16a34a` · `#0891b2` · `#4f46e5` · `#7c3aed` · `#db2777`

---

## Screen Design

### Navigation structure
- **4-tab floating Liquid Glass tab bar:** Home · Players · History · Shelf
- **Score entry flow** (Setup → Scoring → Results) — full-screen covers layered over the Home tab; tab bar hidden during the flow
- **Settings** — sheet presented from the gear icon in the Shelf nav bar; not a tab

### Home tab
- **Resume banner** (conditional) — shown when a `GameSession.completedAt == nil` session exists; tap jumps directly into Scoring. Only one in-progress session is kept at a time: starting a new game automatically discards the previous unfinished session.
- **Featured card** — most-played game by session count; displays artwork, title, play count, and "Start a game" CTA
- **Other games strip** — horizontally scrollable small cards sorted by play frequency, each showing icon, title, and player count range

### Game Setup (full-screen cover over Home)
- Nav bar: Cancel (left) · game title (centre) · "X / max" player count (right)
- **Player bubbles** — Apple Watch-style cluster of selected players; long press a bubble to reveal × removal badge; short tap has no effect in normal state; dashed "New" bubble creates a player inline
- **Roster section** — below the bubble cluster; "Add from roster" divider + roster list rows with "+" to add
- CTA: "Start scoring →" — disabled until `minPlayers` is reached

### Score Entry (full-screen cover over Home)
- Nav bar: ← back (triggers discard alert) · game title · **Finish** button (right)
- **Discard alert** — tapping back shows "Discard scores?" dialog with Cancel / Discard; Discard returns to Setup
- **Player strip** — prev ‹ · player avatars · next ›; active player: 38 pt / full opacity; inactive: 28 pt / 35% opacity; "N of M" label below active avatar; tapping an avatar or using prev/next switches the active player
- **Progress bar** — fills as players are completed
- **Category form** — stepper row per category; `.computed` categories (e.g. Scientific) expand to sub-steppers per symbol
- **Bottom CTA** — "Next player →"

### Results (full-screen cover over Home)
- Trophy icon + winner name (or "Tie!" when `winnerIDs` has multiple entries)
- **Score grid** — players as columns, categories as rows, totals row highlighted
- CTAs: "Play again" (secondary) · "Save & exit" (primary)

### Players tab
- Large-title nav + "+" to add a new player
- Roster list: avatar circle · name · game count · chevron
- Soft-deleted players (`deletedAt != nil`) excluded
- **Player detail** — large avatar, name, stats (games played / wins / win rate), recent games list; tap "Edit" to edit name and avatar colour inline — no separate edit screen (v1)

### History tab
- Sessions sorted by `createdAt` descending (newest first), grouped by date
- Row: game name · time · winner name · player avatar strip · chevron
- **Filter** (v1) — by game title (single select) or by player (single select); filter sheet accessed via the filter icon in the nav bar
- **Session detail** — same score grid layout as Results screen, read-only

### Empty states
| Screen | Empty condition | What to show |
|--------|----------------|--------------|
| Home | No sessions ever played | Featured card only (no resume banner); "Other games" strip still visible |
| Players | No players in roster | Centred icon + "No players yet" + "Add your first player" CTA |
| History | No completed sessions | Centred icon + "No games recorded yet" |
| Shelf | Always has games (v1 ships with 7 Wonders + Wingspan) | N/A |

### "Play again" flow
Tapping "Play again" on the Results screen:
1. Creates a **new** `GameSession` (new UUID, new `createdAt`), discarding the previous unfinished session rule
2. Pre-selects the same set of players from the just-completed session
3. Navigates back to Setup — user can adjust the player list before starting

### Auto-save during scoring
`PlayerScore` records are written to SwiftData when the user **advances to the next player** (taps "Next player →" or uses prev/next strip). Scores for the active player in-progress are held in local `@State`; they are flushed to SwiftData on advance. If the app is force-quit mid-player, that player's current entries are lost — all other players' scores are preserved. The `GameSession` (`completedAt == nil`) and completed `PlayerScore` rows survive a force-quit.

### Shelf tab
- Game card list: artwork placeholder · title · player range · play count · chevron
- **Settings sheet** — slides up from gear icon in nav bar; General section (haptics, appearance); Danger zone (clear all history)

---

## Data Model (SwiftData)

### Design principles
- **Client-generated UUIDs** on all entities — stable IDs before any network sync
- **`updatedAt` on all entities** — required for future sync conflict resolution
- **Soft delete on Player** (`deletedAt: Date?`) — deleted profiles vanish from roster UI but all history and scores remain intact and linked; also serves as tombstoning for sync
- **`categoryScores` as `[String: Double]` JSON** — game-agnostic, no migration needed when adding new games, handles fractional VP

### Player
| Field | Type | Notes |
|-------|------|-------|
| `id` | `UUID` | Primary key, client-generated |
| `name` | `String` | Preserved in history even after soft-delete |
| `avatarColor` | `String` | Hex color |
| `createdAt` | `Date` | |
| `updatedAt` | `Date` | Set on every mutation — required for sync |
| `deletedAt` | `Date?` | Soft delete: nil = active, non-nil = removed from roster |
| `scores` | `[PlayerScore]` | Never cascade-deleted |

### GameSession
| Field | Type | Notes |
|-------|------|-------|
| `id` | `UUID` | Primary key, client-generated |
| `gameID` | `String` | e.g. `"7wonders"` — never a typed ref, keeps history game-agnostic |
| `gameName` | `String` | Display name snapshot at time of play |
| `createdAt` | `Date` | When the session was started; primary sort key for History |
| `completedAt` | `Date?` | nil = in progress / resumable; non-nil = finished |
| `updatedAt` | `Date` | Sync conflict resolution |
| `winnerIDs` | `[UUID]` | One entry = solo winner; multiple = tie. `Player.id` snapshots — survive player deletion |
| `playerScores` | `[PlayerScore]` | Cascade delete with session |

### PlayerScore (join entity)
| Field | Type | Notes |
|-------|------|-------|
| `id` | `UUID` | Primary key, client-generated |
| `player` | `Player` | Relationship, no cascade |
| `session` | `GameSession` | Relationship |
| `totalScore` | `Double` | Fractional VP supported; negative values supported for penalty-heavy games (e.g. Agricola, Azul) |
| `categoryScores` | `Data` | JSON-encoded `[String: Double]` keyed by category ID |
| `rank` | `Int` | 1 = winner; tied players share the same rank (1, 1, 3 for a two-way tie at top) |
| `updatedAt` | `Date` | Sync conflict resolution |

### Soft delete query pattern
All roster queries filter `deletedAt == nil`. History queries join on `Player` freely — deleted players still appear in past games under their preserved name.

### Sync readiness
`updatedAt` on all entities + client UUIDs + soft deletes = compatible with CloudKit, a REST backend, or any CRDT-based sync layer. No structural changes needed when sync is added.

---

## 7 Wonders — Scoring Categories (v1)

**Protocol values:** `minPlayers = 2`, `maxPlayers = 7`, `tieBreaker = .byCategory("treasury")`
(Ties broken by most coins remaining; if still tied, the victory is shared — `winnerIDs` holds both.)

| Category | `CategoryInputType` | Calculation |
|----------|---------------------|-------------|
| ⚔️ Military | `.integer` | Enter total conflict VP (+1/+3/+5/−1 tokens) directly |
| 💰 Treasury | `.integer` | Enter coin count; app calculates `floor(coins / 3)` VP |
| 🏛 Wonders | `.integer` | Enter VP from completed wonder stages |
| 🔵 Civilian | `.integer` | Enter sum of printed VP on blue cards |
| 🟡 Commercial | `.integer` | Enter VP from yellow card effects |
| 🟢 Scientific | `.computed(["gears","compasses","tablets"])` | App calculates VP from symbol counts |
| 🟣 Guilds | `.integer` | Enter VP based on neighbours' structures |

### Scientific scoring formula (implement carefully)
Given counts `g` (gears), `c` (compasses), `t` (tablets):
```
sets = min(g, c, t)
vp = (sets × 7) + score(g) + score(c) + score(t)

where score(n) = 0 if n==0, 1 if n==1, 4 if n==2, 9 if n>=3
     (i.e. n² capped: always use the best 3 for the set bonus first)
```

---

## Wingspan — Scoring Categories (v1)

**Protocol values:** `minPlayers = 1`, `maxPlayers = 5`, `tieBreaker = .none`
(Ties result in shared victory — all tied players appear in `winnerIDs`. No official tiebreaker in the base game.)
Base game only; no expansions.

| Category | `CategoryInputType` | Notes |
|----------|---------------------|-------|
| Birds | `.integer` | Sum of printed VP on played bird cards |
| Bonus cards | `.integer` | VP from achieved bonus card objectives |
| End-of-round goals | `.integer` | Total VP accumulated from round-end goal tiles |
| Eggs | `.integer` | 1 VP per egg remaining on bird cards |
| Cached food | `.integer` | 1 VP per food token cached on bird cards |
| Tucked cards | `.integer` | 1 VP per card tucked under bird cards |

---

## Architecture Constraints

- **`ScoringGame` protocol:** Each game conforms to a protocol defining the full contract below. 7 Wonders is the first conformer. History and player systems are completely unaware of game-specific logic.

  ```swift
  protocol ScoringGame {
    var id: String { get }            // e.g. "7wonders" — matches GameSession.gameID
    var name: String { get }          // display name
    var minPlayers: Int { get }       // enforced in game setup UI
    var maxPlayers: Int { get }       // enforced in game setup UI
    var categories: [ScoreCategory] { get }
    var tieBreaker: TieBreakerRule { get }
    func calculateScores(inputs: [String: Double]) -> [String: Double]
  }

  struct ScoreCategory {
    let id: String                    // key used in categoryScores JSON
    let name: String
    let inputType: CategoryInputType
  }

  enum CategoryInputType {
    case integer                      // direct VP or raw count entry
    case computed([String])           // symbol IDs fed into calculateScores; app derives VP
    case checkbox                     // scored (1.0) or not (0.0)
  }

  enum TieBreakerRule {
    case none                         // ties are valid final outcomes
    case byCategory(String)           // highest value in named category breaks tie (e.g. "treasury")
    case manual                       // app prompts the group to declare winner
  }
  ```

  **`calculateScores` contract** — receives a flat `[String: Double]` of all raw inputs (direct category values + sub-inputs for `.computed` categories), returns a `[String: Double]` of derived VP values for computed categories only. The caller merges the result with the direct inputs to build the final `categoryScores` dictionary stored on `PlayerScore`. Example for 7 Wonders: inputs include `"scientific_gears": 3`, `"scientific_compasses": 2`, `"scientific_tablets": 1`; output is `"scientific": 18` (computed VP). Treasury input is `"treasury_coins": 9`; output is `"treasury": 3` (floor division).

  **Player count** — game setup enforces `minPlayers`/`maxPlayers` from the selected game. The global 2–7 range in the UI is only a fallback; each game declares its own bounds.

  **Tie handling** — `TieBreakerRule.byCategory` triggers automatic resolution; `.manual` shows a prompt; `.none` allows multiple entries in `GameSession.winnerIDs`. `PlayerScore.rank` uses standard competition ranking (1, 1, 3 for a two-way tie at the top).
- **Minimum deployment target:** iOS 26. Liquid Glass visual language throughout.
- **Navigation:** 4-tab floating Liquid Glass tab bar (`Home`, `Players`, `History`, `Shelf`). Score entry and results presented as full-screen covers layered over Home. Settings accessible via gear icon in the Shelf nav bar — not a tab.
- **Single in-progress session:** At most one `GameSession` with `completedAt == nil` may exist at any time. When the user starts a new game, any existing unfinished session is deleted before the new one is created.
- **Local-first:** SwiftData, no backend, no iCloud sync in v1.
- **No third-party dependencies v1:** Pure SwiftUI + Apple frameworks only.
- **Game config is preset:** Game scoring rules, categories, and player bounds are hardcoded per conformer. No in-app editing of game configuration in v1. A game detail/config screen is post-v1.
- **History is game-agnostic:** `GameSession` stores a `gameID` string, not a typed reference. New games added without schema migration.
- **Always set `updatedAt`:** Every model mutator must update `updatedAt = Date()`.

---

## Input Modes (Phased)

### Phase 1 — guided form (v1)
- Manual per-category entry, one player at a time
- Instant total calculation, winner screen, auto-save to history

### Phase 2 — smart input (post-v1)
- Voice: "Alice military 5, treasury 3..."
- Camera: scan score sheet or card layout

### Phase 3 — insights (post-v1)
- Leaderboard, win rates, avg score per category per player
- Additional games (Catan, Ticket to Ride, etc.)

---

## Success Criteria (v1)

- [ ] Score a full 7 Wonders game in under 2 minutes
- [ ] Score a full Wingspan game in under 2 minutes
- [ ] Scientific VP formula calculates correctly (7 Wonders)
- [ ] Player count range enforced per game (1–5 for Wingspan, 2–7 for 7 Wonders)
- [ ] Player roster persists across app launches
- [ ] Inline player profile creation during game setup
- [ ] Game history saved with scores linked to player profiles
- [ ] Deleted players preserved in history under their name
- [ ] Runs on iOS 26+, Liquid Glass tab bar and navigation
