# Swift Style Guide (Condensed)
> Derived from the [Google Swift Style Guide](https://google.github.io/swift/). Personal project baseline — keep it simple and consistent.

---

## Naming

- **Types & protocols:** `UpperCamelCase` — `ScoreBoard`, `GameSession`
- **Variables, functions, params:** `lowerCamelCase` — `playerScore`, `addPlayer()`
- **Booleans:** prefix with `is`, `has`, `can` — `isGameOver`, `hasWinner`
- **Avoid abbreviations** — `playerCount` not `plrCnt`

## Formatting

- **Indent:** 2 spaces (no tabs)
- **Line limit:** 100 characters
- **Braces:** K&R style — opening brace on the same line, closing brace on its own line
- **No semicolons**
- **One statement per line**
- Blank line between logical sections; no trailing whitespace

```swift
// Good
func calculateScore(for player: Player) -> Int {
  let base = player.points
  return base + bonusPoints
}

// Bad
func calculateScore(for player: Player) -> Int { let base = player.points; return base + bonusPoints }
```

## Declarations

- Prefer `let` over `var` whenever possible
- Use explicit types only when the compiler can't infer them
- Mark everything `private` by default; loosen access only when needed
- Use `// MARK: - Section Name` to organize code sections in a file

```swift
let maxPlayers = 4
private var scores: [String: Int] = [:]

// MARK: - Scoring
func addScore(_ points: Int, for player: String) { ... }
```

## Optionals

- **Never force-unwrap** (`!`) in production code — use `if let`, `guard let`, or `??`
- Use `guard let` for early exits to reduce nesting

```swift
// Good
guard let winner = players.first else { return }
let name = player.name ?? "Unknown"

// Bad
let winner = players.first!
```

## Types

- Prefer `struct` over `class` for data models (value semantics)
- Use `enum` for fixed sets of states — `GamePhase`, `ScoreCategory`
- Conform to `Codable` on data models that need persistence

```swift
struct Player: Codable {
  let id: UUID
  var name: String
  var score: Int
}

enum GamePhase {
  case setup, inProgress, finished
}
```

## Functions & Closures

- Keep functions short and single-purpose
- Use argument labels that read naturally at the call site — `add(player:)` → `add(player: alice)`
- Trailing closure syntax for the last closure argument when it aids readability

```swift
players.sorted { $0.score > $1.score }
```

## Error Handling

- Use `throws` / `try` for recoverable errors
- Avoid `try!` — use `try?` when a nil result is acceptable

## Comments

- Write comments only when the **why** is non-obvious; skip what the code already says
- Use `///` doc comments on public-facing types and functions
- Use `// MARK: -` to divide logical sections

---

*Source: Google Swift Style Guide — https://google.github.io/swift/*
