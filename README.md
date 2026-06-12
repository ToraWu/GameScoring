# GameScoring

An iOS app to assist offline board game players in tracking and calculating scores after games end.

## Project Structure

```
GameScoring/
├── docs/               # PRD, design specs, and documentation
├── assets/             # Images, icons, and other assets
├── GameScoring/        # Xcode project source files (to be generated)
└── README.md
```

## Setup

```bash
brew install xcodegen   # one-time
xcodegen generate       # regenerate GameScoring.xcodeproj from project.yml
open GameScoring.xcodeproj
```

## Status

- [x] PRD received
- [x] Xcode project created (generated via xcodegen from `project.yml`)
- [ ] Data model implemented
- [ ] Core scoring logic implemented
- [ ] UI built
- [ ] Testing complete
