# BoardScore — UX Design Spec
**Version:** 1.0  
**Reflects:** PRD 2.1 wireframe decisions  
**Updated:** June 2026

---

## Screen Inventory

| Screen | Type | Entry point |
|--------|------|-------------|
| Home | Tab root | Tab bar |
| Game Setup | Full-screen cover | Home "Start" / "Resume" |
| Score Entry | Full-screen cover | Setup "Start scoring →" |
| Results | Full-screen cover | Score Entry "Finish" |
| Players | Tab root | Tab bar |
| Player Detail | Drill-in | Players list row |
| History | Tab root | Tab bar |
| Session Detail | Drill-in | History list row |
| Shelf | Tab root | Tab bar |
| Settings | Sheet | Shelf nav gear icon |

---

## Home Tab

### Layout
```
┌─────────────────────────────┐
│ 9:41                  ⊶ ⬛  │  ← status bar
├─────────────────────────────┤
│ BoardScore                  │  ← large title
│ ┌─────────────────────────┐ │
│ │ ● In progress · 3 of 4  │ │  ← resume banner (conditional)
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │  [artwork placeholder]  │ │
│ │  ████████               │ │  ← featured game card
│ │  ██████████████         │ │
│ │  [ Start a game       ] │ │
│ └─────────────────────────┘ │
│ OTHER GAMES                 │
│ ┌────┐ ┌────┐ ┌────┐       │  ← horizontal scroll
│ │    │ │    │ │    │       │
│ └────┘ └────┘ └────┘       │
│                             │
│ ╔═══╗  ─────  ─────  ─────  │  ← tab bar (Liquid Glass)
│ Home  Players History Shelf │
└─────────────────────────────┘
```

### Behaviors
- **Resume banner**: visible when any `GameSession.completedAt == nil` exists; taps into Score Entry at the saved player position
- **Featured card**: sorted by descending session count; always shows one game even if count = 0
- **Other games strip**: excludes the featured game; sorted by frequency; muted state for 0-play games

---

## Game Setup (Full-Screen Cover)

### Layout
```
┌─────────────────────────────┐
│ Cancel   7 Wonders    3 / 7 │  ← nav bar
├─────────────────────────────┤
│                             │
│       ○       ●       ○     │  ← bubble cluster
│           ○       +         │    (Apple Watch grid)
│                             │
│  ── Add from roster ──      │
│  ○ ████████████         +   │
│  ○ ██████               +   │
│  ○ ████████████████     +   │
│                             │
│ [ Start scoring →         ] │  ← CTA (disabled < minPlayers)
└─────────────────────────────┘
```

### Interactions
| Gesture | Target | Result |
|---------|--------|--------|
| Tap "+" bubble | Dashed bubble | Inline new player form |
| Long press bubble | Selected player bubble | × badge appears; tap × removes |
| Short tap bubble | Selected player bubble | No action |
| Tap "+" in roster row | Roster player | Adds to bubble cluster |
| Tap Cancel | Nav | Dismisses cover, returns to Home |

### Constraints
- Player count shown as "X / max" in nav bar; "Start scoring →" disabled when count < `minPlayers`
- New player created inline joins both the session and the global roster

---

## Score Entry (Full-Screen Cover)

### Layout
```
┌─────────────────────────────┐
│ ←      7 Wonders    Finish  │  ← nav; ← triggers discard alert
├─────────────────────────────┤
│ ████████████████████░░░░░░  │  ← progress bar (75%)
│ [‹] ○  ○  ●  ○  [›]        │  ← player strip
│         Alice               │    active: 38pt / 100% opacity
│         3 of 4              │    inactive: 28pt / 35% opacity
├─────────────────────────────┤
│ □ Military             VP   │
│ [ −  |  0  |  + ]          │
│ □ Treasury          coins   │
│ [ −  |  0  |  + ]          │
│ □ Scientific    3 symbols   │
│   ⚙ [ −  0  + ]            │  ← sub-steppers for computed
│   ⊕ [ −  0  + ]
│   📖 [ −  0  + ]
│ □ Civilian    (collapsed)   │
├─────────────────────────────┤
│ [ Next player →           ] │
└─────────────────────────────┘
```

### Interactions
| Action | Result |
|--------|--------|
| Tap ← in nav | Discard alert: "Discard scores?" → Cancel / Discard |
| Discard | Navigates back to Setup, clears all entered data |
| Tap Finish | Navigates to Results; triggers score calculation |
| Tap ‹ / › in strip | Switches active player (wraps around) |
| Tap inactive avatar in strip | Switches to that player |
| Tap "Next player →" | Advances to next player; on last player, behaves as Finish |

---

## Results (Full-Screen Cover)

### Layout
```
┌─────────────────────────────┐
│ ←       Results             │  ← nav (no right action)
├─────────────────────────────┤
│          🏆                 │
│        Alice won            │
│                             │
│         A    B    C    D    │  ← columns = players
│ Total   68   54   61   57   │  ← totals row (highlighted)
│ Military 12   8    6    9   │
│ Treasury  6   9    7    6   │
│ Wonders   7  10    8    6   │
│ Civilian  …   …    …    …   │
│ Sci.      …   …    …    …   │
│ Guilds    …   …    …    …   │
├─────────────────────────────┤
│ [ Play again ] [Save & exit]│
└─────────────────────────────┘
```

### Behaviors
- **Winner:** derived from `PlayerScore.rank == 1`; if multiple, shows "Tie! Alice & Bob"
- **"Play again":** resets score data, returns to Setup with same players pre-selected
- **"Save & exit":** saves session (`completedAt = Date()`), pops all covers to Home
- **No "Done" button** — the two CTAs cover all exit paths

---

## Players Tab

### Player List
```
┌─────────────────────────────┐
│ Players                   + │
├─────────────────────────────┤
│ ○ ████████████  12 games  › │
│ ○ ██████         8 games  › │
│ ○ ████████████   3 games  › │
│ ○ ████████████  21 games  › │
└─────────────────────────────┘
```

### Player Detail (drill-in)
```
┌─────────────────────────────┐
│ ←      (name)          Edit │  ← Edit toggles inline edit mode
├─────────────────────────────┤
│          [  ○  ]            │  ← large avatar (72pt)
│        ████████████         │  ← in edit mode: tappable colour picker
│        ██████               │  ← in edit mode: tappable name field
│                             │
│ ── Stats ─────────────────  │
│ Games played        12      │
│ Wins                 5      │
│ Win rate            42%     │
│                             │
│ ── Recent games ─────────── │
│ 7 Wonders  Jun 11   Winner  │
│ 7 Wonders  Jun 8            │
│ 7 Wonders  Jun 5    Winner  │
└─────────────────────────────┘
```

**Edit mode (v1, inline only):**
- Tap "Edit" → nav bar shows "Cancel" (left) and "Save" (right); "Edit" disappears
- Name becomes a tappable text field
- Avatar circle shows a colour picker beneath it (predefined palette, ~8 colours)
- No separate edit screen

---

## History Tab

### Session List
```
┌─────────────────────────────┐
│ History                   ⊞ │  ← filter icon (game title / player)
├─────────────────────────────┤
│ Today                       │  ← grouped by createdAt date
│ 7 Wonders · 2:30 PM         │
│ Alice won  ○ ○ ○ ○        › │
│                             │
│ June 8                      │
│ 7 Wonders · 8:15 PM         │
│ Bob won    ○ ○ ○ ○ ○      › │
└─────────────────────────────┘
```

Default sort: `createdAt` descending (newest first). Sessions grouped by date (Today / date string for earlier).

### Filter Sheet (slides up from ⊞)
```
┌─────────────────────────────┐
│ ▬▬▬  Filter              Clear│
├─────────────────────────────┤
│ Game                        │
│  ○  7 Wonders               │  ← single select
│                             │
│ Player                      │
│  ○  Alice                   │  ← single select
│  ○  Bob                     │
│  ○  Carol                   │
│              [ Apply ]      │
└─────────────────────────────┘
```

Filters are OR'd within a field but AND'd across fields (show sessions of game X that include player Y). Both filters optional; either alone narrows the list.

### Session Detail (drill-in)
Same score grid as Results screen, read-only. Nav bar shows game title (left back arrow) and date string (right, non-interactive).

---

## Shelf Tab

### Game List
```
┌─────────────────────────────┐
│ Shelf                     ⚙ │  ← gear → Settings sheet
├─────────────────────────────┤
│ ┌──────────────────────────┐│
│ │ [art] 7 Wonders          ││
│ │       2–7 players        ││
│ │       12 times played  › ││
│ └──────────────────────────┘│
│ ┌──────────────────────────┐│
│ │ [  ] More games coming…  ││  ← muted placeholder
│ └──────────────────────────┘│
└─────────────────────────────┘
```

### Settings Sheet (slides up from gear)
```
┌─────────────────────────────┐
│ ▬▬▬  (drag handle)          │
│ Settings                Done│
├─────────────────────────────┤
│ General                     │
│ Haptics              ● ─── │
│ Appearance           System │
├─────────────────────────────┤
│ Danger zone                 │
│ Clear all history      [red]│
├─────────────────────────────┤
│ BoardScore v1.0 (1)         │
└─────────────────────────────┘
```

---

## Decisions Log

| Question | Decision |
|----------|----------|
| Player editing: inline or separate screen? | Inline only (v1) — name field + colour picker, Cancel/Save in nav bar |
| History sort order? | `createdAt` descending by default, grouped by date |
| History filter scope? | Game title (single select) and player (single select); date range post-v1 |
| Multiple in-progress sessions? | Only one allowed; starting a new game discards any existing unfinished session |
| Visual style? | **Warm Table** — cream `#faf5ed`, amber `#b45309`, mahogany `#92400e`; crown icon |
| Game config screen? | Post-v1; v1 ships with preset configs for 7 Wonders and Wingspan |
| "Play again" flow? | Creates new session, pre-selects same players, navigates to Setup |
| Auto-save granularity? | Flush active player's scores to SwiftData on "next player" advance; in-progress player's state held in `@State` |
| v1 games? | 7 Wonders and Wingspan, base game only, no expansions |

## Open Questions

_None remaining for v1._
