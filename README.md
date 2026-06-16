# GameScoring

An iOS app to assist offline board game players in tracking and calculating scores after games end.

## Project Structure

```
GameScoring/
├── docs/                       # PRD, design specs, and documentation
├── assets/                     # Images, icons, and other assets
├── app/                        # Xcode project
│   ├── project.yml             # xcodegen spec (source of truth)
│   ├── GameScoring.xcodeproj   # generated — do not edit by hand
│   └── GameScoring/            # Swift source
│       ├── Models/             # SwiftData @Model entities
│       ├── GameScoringApp.swift
│       └── ContentView.swift
└── README.md
```

## Setup

```bash
brew install xcodegen          # one-time
cd app && xcodegen generate    # regenerate GameScoring.xcodeproj from project.yml
open GameScoring.xcodeproj
```

## Status

- [x] PRD received
- [x] Xcode project created (generated via xcodegen from `app/project.yml`)
- [x] Data model implemented (`Player`, `GameSession`, `PlayerScore`)
- [x] Game layer (`ScoringGame` protocol; 7 Wonders, Wingspan, Carcassonne, Ticket to Ride; `GameRegistry`)
- [x] M1 — Navigation shell (4-tab Liquid Glass `TabView`, Warm Table theme)
- [x] M2 — Players tab (roster CRUD: add, inline edit, swipe soft-delete)
- [x] M3 — Setup flow (game picker → player select → create GameSession)
- [x] M4 — Scoring screen (live inputs, computed VP, ranking, Finish/discard)
- [x] M5 — Results screen (ranked standings, winner crown, tie badge, breakdown)
- [x] M6 — History + Home tabs (filter, session detail, resume, featured game)
- [x] M7 — Polish (edge cases, keyboard dismiss, empty-state copy, visual QA)
- [x] Testing complete (unit + UI tests)

**v1 feature-complete.**

### v1.01 (scoring/results refinements)
- [x] Score Entry: pinned collapsing header, stepper inputs, per-category
  icons, negative scores, solid-vs-placeholder zero, scroll-to-top on switch,
  last-player Finish, full-screen background
- [x] Results: category icons in breakdown, Edit (revise & re-rank), Play again
- [x] Per-category icon/colour system; `PlayerScore.rawInputs` for revision
- [x] In-app version (release + dev build) on the Home footer
- [x] XCUITest target driving the scoring/results flows
- [x] App locked to light appearance (Warm Table is light-only)
