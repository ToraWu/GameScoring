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
- [ ] Core scoring logic implemented
- [ ] UI built
- [ ] Testing complete
