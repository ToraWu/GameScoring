# BoardScore — UX Design Spec
**Version:** 1.01  
**Reflects:** PRD 2.1 wireframe decisions + v1.01 scoring/results refinements  
**Updated:** June 2026

> **v1.01 changelog (this revision):** Score Entry pinned/collapsing header,
> stepper inputs with negative support, per-category icon + colour system,
> solid-vs-placeholder zero, scroll-to-top on player switch, last-player Finish.
> Results: edit-scores (revise & re-finish), category icons in the breakdown,
> "Play again" with the same settings. App version (release + dev build) shown
> in-app. See **v1.01 Notes** at the end.

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
│ Back    7 Wonders   Finish  │  ← nav; Back triggers discard alert
├─────────────────────────────┤  ╮
│  ○  ●  ○  ○                 │  │ PINNED header (does not scroll)
│         Alice               │  │ collapses as the form scrolls:
│         15 VP               │  │  · expanded: avatars + name + big total
├─────────────────────────────┤  ╯  · collapsed: small avatars + inline total
│ 🛡 Military           [−] 5 [+] │  ← scrolls; icon tinted by category colour
│ 🪙 Treasury          [−] 0 [+] │     0 untouched = placeholder grey
│ 🏛 Wonders           [−] 0 [+] │
│ 🏢 Civilian          [−] 0 [+] │
│ ⚛ Science            10 VP    │  ← computed: read-only, live
│ 🛒 Commerce          [−] 0 [+] │
│ 👥 Guilds            [−] 0 [+] │
│ ─ Symbols ─                 │
│ 🧭 Compass           [−] 1 [+] │
│ 📖 Tablet            [−] 1 [+] │
│ ⚙ Gear              [−] 1 [+] │
├─────────────────────────────┤
│ [ ‹ Previous ]  [ Next › ]  │  ← Next becomes "Finish ✓" on last player
└─────────────────────────────┘
```

### Header (pinned + collapsing)
- The **player strip + current total are pinned** above the scrolling form — they never scroll off.
- As the form scrolls **down**, the header **collapses** to reclaim space: the big total shrinks to an inline value and avatars shrink; scrolling back up re-expands it. Driven by scroll offset (`onScrollGeometryChange`).
- Background fills the **entire screen** (ignores the bottom safe area) so no gap shows above the keyboard.

### Inputs
- Each direct category is a **stepper**: `[ − ]  value  [ + ]`. The value is also tappable for direct keypad entry; − / + adjust by 1 (long-press to repeat).
- **Per-category icon**, tinted with the game's colour system (see *Category Visual System*), shown left of the label for fast identification.
- **Negative-capable categories** (e.g. 7 Wonders Military) allow values below 0 via the stepper / a leading `−` on the keypad; **negative values render in a distinct colour** (red `#dc2626`).
- **Computed categories** (e.g. Science) stay read-only and update live as their source inputs change.
- **Zero display:** an *untouched* field shows a grey placeholder `0`; once the user edits it (steps or types), the value — including an explicit `0` — renders in the **solid** text colour.
- **Keyboard dismissal:** scrolling dismisses the keypad (interactive); tapping outside a field also dismisses. **No separate "Done" toolbar button.**

### Interactions
| Action | Result |
|--------|--------|
| Tap Back in nav | Discard alert: "Discard scores?" → Cancel / Discard |
| Discard | Deletes the in-progress session, returns to Setup |
| Tap Finish (nav) | Ranks, completes the session, navigates to Results |
| Tap an avatar in the strip | Switches active player; **form scrolls back to top** |
| Tap ‹ Previous / Next › | Moves between players; **form scrolls to top** |
| Next › on the **last** player | Renders as **Finish ✓** and finishes the game |

---

## Results (Full-Screen Cover)

### Layout
```
┌─────────────────────────────┐
│ Edit    Results      Done   │  ← Edit (revise) · Done (exit flow)
├─────────────────────────────┤
│          👑                 │
│       Alice wins!           │  (or "It's a tie!" + names)
│ ┌─────────────────────────┐ │
│ │ ①  Ⓐ Alice    👑   25 VP│ │  ← ranked card per player
│ │ 🛡15  🪙5  ⚛10  …       │ │  ← breakdown chips WITH category icons
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ ②  Ⓑ Bob          18 VP │ │
│ └─────────────────────────┘ │
├─────────────────────────────┤
│ [  ↻  Play again         ]  │  ← same game + same players
└─────────────────────────────┘
```

### Behaviors
- **Winner:** derived from `PlayerScore.rank == 1`; multiple winners → "It's a tie!" + names.
- **Breakdown chips show the category icon** (same icon/colour system as Score Entry) next to each value.
- **Edit (revise):** returns to the Score Entry screen for this session with the entered values restored; the user can change scores and tap Finish again to **re-rank and re-complete** the same session. Requires raw inputs to be retained on the session (not just computed VP).
- **Play again:** opens **Game Setup pre-loaded with the same game and the same players selected** — one tap from a finished game to the next. Starting it creates a fresh session (the finished one stays in History).
- **Done:** dismisses the whole flow back to the launching tab.

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
| Score Entry header behaviour (v1.01)? | Player strip + total **pinned**, collapse on scroll to reclaim space |
| Score input control (v1.01)? | `[ − ] value [ + ]` stepper; value tappable for keypad entry |
| Negative scores (v1.01)? | Per-category `allowsNegative`; negatives rendered red `#dc2626` |
| Category icons (v1.01)? | Each category carries an SF Symbol + colour (game colour system) |
| Edit after finish (v1.01)? | Results → Edit returns to Score Entry; re-Finish re-ranks the same session |
| Replay (v1.01)? | Results → Play again opens Setup with same game + same players |
| App version display (v1.01)? | Release + dev build shown on Home footer; dev build bumps per commit |

## Category Visual System (v1.01)

Each `ScoreCategory` gains an **`icon`** (SF Symbol) and **`colorHex`** drawn from the
game's own colour identity, used in Score Entry rows and Results breakdown chips.

**7 Wonders** (matches the box's card colours):

| Category | Icon | Colour |
|----------|------|--------|
| Military | `shield.fill` | red `#c0392b` |
| Treasury | `centsign.circle.fill` | gold `#caa53d` |
| Wonders | `building.columns.fill` | stone `#8a6d3b` |
| Civilian | `building.2.fill` | blue `#2f6fb0` |
| Science | `atom` | green `#3a8f5a` |
| Commerce | `cart.fill` | amber `#d4a12a` |
| Guilds | `person.3.fill` | purple `#7e5aa8` |
| Compass / Tablet / Gear / Wild | `safari` / `book.closed.fill` / `gearshape.fill` / `star.fill` | green tints |

**Wingspan:** Birds `bird.fill`, Bonus `rosette`, End-of-Round `flag.checkered`,
Eggs `oval.fill`, Cached Food `leaf.fill`, Tucked `rectangle.stack.fill`.

**Carcassonne:** Cities `building.2.fill`, Roads `road.lanes`, Cloisters
`building.columns.fill`, Fields `leaf.fill`.

Military is the canonical `allowsNegative` category (defeat tokens score −1).

## v1.01 Notes — data & version

**Model changes required:**
- `ScoreCategory` adds `icon: String`, `colorHex: String`, `allowsNegative: Bool` (default false).
- `PlayerScore` adds `rawInputsData` (JSON `[String: Double]`) so raw entries are
  retained for **Edit/revise** — `categoryScores` keeps computed VP, `rawInputsData`
  keeps what the user typed. (Replaces the prior hack of stashing raw inputs in
  `categoryScores` while in progress.)
- `GameSetupView` gains an `initialPlayerIDs` parameter for **Play again**.

**Versioning / About:**
- Show **release version** (`CFBundleShortVersionString`, e.g. `1.0.1`) and **dev
  build** (`CFBundleVersion`, an integer) on the Home tab footer, e.g.
  `BoardScore 1.0.1 · build 14`.
- The dev build number is bumped on **every commit** (see CLAUDE.md).

## Open Questions

_None remaining for v1.01._
