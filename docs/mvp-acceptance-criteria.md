# MVP Acceptance Criteria (Detailed)

**Project:** Order Game
**Version:** 1.0
**Date:** 2025-10-27

This document provides detailed acceptance criteria for all MVP features, using the **Given/When/Then** (Gherkin-style) format.

---

## Feature 1: Rock Breaking

**User Story:**
As a player, I want to click on rocks to break them, so I can collect the minerals inside.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 1.1: Single-HP Rock Breaking
```gherkin
Given a "Stone Rock" with 1 HP is displayed on the playfield
When the player clicks on the rock sprite
Then the rock immediately shatters (disappears)
And a "crunch" sound effect plays at 70% volume
And 5-10 mineral particles spawn at the rock's position
And a subtle screen shake effect occurs (2px, 100ms)
```

#### AC 1.2: Multi-HP Rock Breaking
```gherkin
Given a "Granite Rock" with 2 HP is displayed on the playfield
When the player clicks the rock once
Then the rock shows a visual crack sprite
And a "thunk" sound effect plays
And the rock's HP decreases to 1
When the player clicks the rock a second time
Then the rock shatters completely
And minerals spawn as per AC 1.1
```

#### AC 1.3: Visual Feedback on Click
```gherkin
Given any rock is on screen
When the player hovers the cursor over it
Then the cursor changes to a "hammer" icon
When the player clicks the rock
Then the rock sprite flashes white for 50ms (hit feedback)
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-1.1 | Click Stone Rock (1 HP) | Rock breaks, SFX plays, 5-10 minerals spawn | ⬜ |
| TC-1.2 | Click Granite Rock (2 HP) twice | First click: crack appears. Second click: break | ⬜ |
| TC-1.3 | Hover over rock | Cursor changes to hammer | ⬜ |
| TC-1.4 | Click empty space | No action, rock unaffected | ⬜ |

---

## Feature 2: Mineral Spawning

**User Story:**
As a player, I want minerals to scatter naturally when a rock breaks, so it feels dynamic and rewarding.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 2.1: Physics-Based Scatter
```gherkin
Given a rock breaks at position (x, y)
When the mineral spawning logic executes
Then 5-10 minerals spawn at (x, y) with random velocity vectors
And each mineral has a 2D physics body with gravity enabled
And minerals bounce once upon hitting the ground (elasticity 0.3)
And minerals come to rest within 3 seconds
```

#### AC 2.2: Loot Table Randomization
```gherkin
Given a "Stone Rock" loot table defines:
  - 70% common (ruby, sapphire)
  - 25% uncommon (emerald)
  - 5% rare (topaz)
When the rock breaks
Then the spawned minerals respect the loot table probabilities
And at least 1 common mineral is guaranteed
And rare minerals appear ~1 in 20 breaks (statistically)
```

#### AC 2.3: Visual Spawn Feedback
```gherkin
Given minerals spawn from a broken rock
When they appear on screen
Then each mineral has a "sparkle" particle effect on spawn (200ms)
And minerals fade in with alpha tween (0 → 1 over 150ms)
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-2.1 | Break Stone Rock | 5-10 minerals spawn with scatter physics | ⬜ |
| TC-2.2 | Break 20 Stone Rocks | ~70% common, ~25% uncommon, ~5% rare (average) | ⬜ |
| TC-2.3 | Observe spawn | Sparkle effect + fade-in visible | ⬜ |
| TC-2.4 | Break rock near edge | Minerals bounce off screen boundaries | ⬜ |

---

## Feature 3: Auto-Collection

**User Story:**
As a player, I want minerals near my cursor to automatically collect, so I don't need to click each one individually.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 3.1: Auto-Collect Radius
```gherkin
Given minerals are in a "resting" state (velocity near zero)
When the player's cursor is within 100 pixels of a mineral
Then the mineral flies toward the cursor with a smooth lerp (speed: 300px/s)
And a "ping" sound plays (only once per mineral collected)
And the mineral disappears upon reaching the cursor
And the inventory counter updates (+1 for that mineral type)
```

#### AC 3.2: Manual Tap Collection (Backup)
```gherkin
Given a mineral is resting outside the auto-collect radius
When the player clicks directly on the mineral sprite
Then the mineral is collected immediately
And all feedback from AC 3.1 applies
```

#### AC 3.3: Collection Feedback
```gherkin
Given a mineral is collected
When it flies toward the cursor
Then it leaves a faint particle trail (3-5 small sparkles)
And the inventory UI shows a "+1" floating text at the mineral's type icon
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-3.1 | Move cursor near resting mineral | Mineral auto-collects with "ping" SFX | ⬜ |
| TC-3.2 | Move cursor away before collection | Mineral stops moving, remains on field | ⬜ |
| TC-3.3 | Click mineral outside radius | Manual collection works | ⬜ |
| TC-3.4 | Collect 5 rubies | Inventory shows "Ruby x5" | ⬜ |

---

## Feature 4: Sorting Bins (2 Types)

**User Story:**
As a player, I want to drag minerals into labeled bins, so I can organize them and earn points.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 4.1: Drag-and-Drop Mechanics
```gherkin
Given the player has collected a ruby (red gem)
And a "Red Gems" bin is visible at the bottom of the screen
When the player clicks the ruby icon in the inventory
And drags it over the Red Gems bin
And releases the mouse button
Then the ruby locks into the bin with a "clink" sound
And the bin progress updates (e.g., 5/10 → 6/10)
And the player earns +10 points
```

#### AC 4.2: Mismatch Rejection (No Penalty)
```gherkin
Given the player drags a ruby to a "Blue Gems" bin
When the drop is released
Then the ruby bounces back to the inventory
And a soft "boop" error sound plays
And no points are deducted
And the bin progress does not change
```

#### AC 4.3: Visual Bin States
```gherkin
Given a bin is empty (0/10)
Then the bin displays a light gray color
Given a bin is partially filled (5/10)
Then the bin displays a progress bar (50% filled, pulsing glow)
Given a bin is full (10/10)
Then the bin glows with a golden sparkle effect
And the bin is marked with a checkmark (✓)
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-4.1 | Drag ruby to Red bin | Locks in, "clink" SFX, +10 points | ⬜ |
| TC-4.2 | Drag ruby to Blue bin | Bounces back, "boop" SFX, no penalty | ⬜ |
| TC-4.3 | Fill bin to 10/10 | Bin glows gold, checkmark appears | ⬜ |
| TC-4.4 | Try to add 11th gem | Bin rejects (full), gem returns to inventory | ⬜ |

---

## Feature 5: Bin Completion Reward

**User Story:**
As a player, I want to feel rewarded when I fill a bin completely, with visual and audio feedback.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 5.1: Completion Trigger
```gherkin
Given a "Red Gems" bin has 9/10 minerals
When the player sorts the 10th red gem correctly
Then the bin immediately triggers a completion event
And a sparkle particle explosion plays (50 particles, 1 second)
And a 3-note harmonious chime (C-E-G major) plays at 70% volume
And the player earns +50 bonus points (displayed as floating text "+50 BONUS!")
```

#### AC 5.2: Multiplier for Next Bin (Optional MVP Feature)
```gherkin
Given a player completed a bin without any mis-sorts
When the next bin starts filling
Then a "2x Streak" indicator appears near the bin
And correct sorts in that bin earn +20 points instead of +10
And the multiplier resets if a mis-sort occurs (no penalty to score)
```

#### AC 5.3: Bin Reset After Completion
```gherkin
Given a bin is completed (10/10)
When the completion animation finishes (2 seconds)
Then the bin resets to 0/10
And the bin criteria remains the same (still "Red Gems")
And a new "capacity milestone" text appears ("You've sorted 10 Red Gems!")
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-5.1 | Complete Red bin (10/10) | Sparkle, chime, +50 bonus, floating text | ⬜ |
| TC-5.2 | Complete bin without errors | Next bin shows 2x multiplier | ⬜ |
| TC-5.3 | Complete bin after 1 error | Next bin has no multiplier (reset) | ⬜ |
| TC-5.4 | Observe bin after completion | Resets to 0/10, same criteria | ⬜ |

---

## Feature 6: Score System

**User Story:**
As a player, I want to see my score increase as I play, but without feeling pressured or punished for mistakes.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 6.1: Score Awarding (All Sources)
```gherkin
Given the player performs the following actions:
  - Breaks 1 Stone Rock (+5)
  - Collects 3 rubies (common, +10 each = +30)
  - Collects 1 emerald (uncommon, +20)
  - Sorts 5 gems correctly (+10 each = +50)
  - Completes 1 bin (+50 bonus)
When all actions complete
Then the total score increases by 5 + 30 + 20 + 50 + 50 = 155 points
And the score counter updates in real-time (no delay)
```

#### AC 6.2: No Penalties
```gherkin
Given the player mis-sorts a gem (drags ruby to Blue bin)
When the gem bounces back
Then the score does not decrease
And no negative feedback is displayed (no red text, no harsh sounds)
```

#### AC 6.3: Optional Combo Bonus (Non-Punishing)
```gherkin
Given the player sorts 5 gems correctly in a row
When the 5th correct sort completes
Then a "+25 SMOOTH OPERATOR" bonus appears
And the combo counter resets to 0
Given the player then mis-sorts a gem
Then the combo resets to 0
And no penalty is applied (just no bonus)
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-6.1 | Perform actions per AC 6.1 | Score increases by 155 | ⬜ |
| TC-6.2 | Mis-sort 3 gems | Score unchanged (no penalty) | ⬜ |
| TC-6.3 | Sort 5 correct in a row | +25 bonus "Smooth Operator" appears | ⬜ |
| TC-6.4 | Break combo after 3 correct | Combo resets, no bonus, no penalty | ⬜ |

---

## Feature 7: Progression Tier 1

**User Story:**
As a player, I want to unlock new content (rocks, minerals, bins) as I play, to feel a sense of growth.

**Priority:** P1 (Important)

### Acceptance Criteria

#### AC 7.1: Unlock Trigger
```gherkin
Given the player has broken 19 Stone Rocks
When the player breaks the 20th rock
Then an "Unlock Achieved!" notification appears (center screen, 3 seconds)
And the notification reads: "New: Granite Rock, +3 Minerals, +1 Bin"
And the unlock is saved to LocalStorage
```

#### AC 7.2: New Content Available
```gherkin
Given Tier 1 is unlocked
When the next rock spawns
Then there is a 30% chance it is a Granite Rock (2 HP)
And new minerals (emerald, topaz, amethyst) can drop from any rock
And a third sorting bin ("Green Gems") appears in the sorting area
```

#### AC 7.3: Persistent Unlock
```gherkin
Given Tier 1 is unlocked
When the player closes the game and reopens it
Then Tier 1 remains unlocked (saved state restored)
And the player does not need to re-earn the unlock
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-7.1 | Break 20th rock | Unlock notification appears for 3s | ⬜ |
| TC-7.2 | Spawn rocks after unlock | 30% Granite, 70% Stone (probabilistic) | ⬜ |
| TC-7.3 | Close and reopen game | Tier 1 still unlocked, new content available | ⬜ |

---

## Feature 8: Save/Load System

**User Story:**
As a player, I want my progress to be saved automatically, so I don't lose my unlocks or score.

**Priority:** P1 (Important)

### Acceptance Criteria

#### AC 8.1: Auto-Save Trigger
```gherkin
Given the player completes a sorting bin
When the bin completion event fires
Then the game serializes the following data to LocalStorage:
  - Current score
  - Unlocked tiers (0, 1, 2, etc.)
  - Inventory contents (mineral counts)
  - Rocks broken count
  - Bins completed count
And the save operation completes within 100ms
```

#### AC 8.2: Load on Launch
```gherkin
Given the player has previously saved data in LocalStorage
When the game launches
Then the DataLoader reads LocalStorage key "order_game_save"
And restores:
  - Score (displayed in HUD)
  - Unlocked tiers (new rocks/minerals available)
  - Inventory (shown in inventory panel)
And if no save exists, initializes a new game (Tier 0, score 0)
```

#### AC 8.3: Save Data Structure
```gherkin
Given a save file is created
Then the LocalStorage JSON structure is:
{
  "version": "1.0",
  "score": 1250,
  "tier": 1,
  "rocks_broken": 23,
  "bins_completed": 5,
  "inventory": {
    "ruby_small": 12,
    "sapphire_small": 8
  }
}
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-8.1 | Complete a bin | Data saved to LocalStorage within 100ms | ⬜ |
| TC-8.2 | Close game, reopen | Score, tier, inventory restored | ⬜ |
| TC-8.3 | Clear LocalStorage, open game | New game initializes (score 0, Tier 0) | ⬜ |
| TC-8.4 | Corrupt save file (invalid JSON) | Game shows error, starts new game | ⬜ |

---

## Feature 9: UI - HUD (Score, Settings)

**User Story:**
As a player, I want a minimal HUD that shows my score and lets me access settings, without cluttering the screen.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 9.1: HUD Layout
```gherkin
Given the game is running
Then the HUD displays:
  - Score counter (top-right, e.g., "Score: 1250")
  - Settings button (gear icon, top-right, 32x32px)
And the HUD occupies <10% of screen height
And the HUD background is semi-transparent (alpha 0.8, dark gray)
```

#### AC 9.2: Settings Button
```gherkin
Given the player clicks the settings button
When the click registers
Then the game pauses (physics freeze)
And a settings panel opens (center screen, 400x300px)
And the panel contains:
  - Volume sliders (Master, SFX, Music)
  - Colorblind Mode toggle
  - "Hide Score" checkbox
  - "Resume" button
```

#### AC 9.3: Real-Time Score Update
```gherkin
Given the player earns points (e.g., +10 from sorting)
When the score increases
Then the HUD score counter updates within 50ms
And the new score animates (scales 1.0 → 1.2 → 1.0 over 200ms)
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-9.1 | Launch game | HUD visible with score + settings button | ⬜ |
| TC-9.2 | Click settings button | Pause menu opens, physics freeze | ⬜ |
| TC-9.3 | Earn +10 points | Score updates <50ms, animates scale | ⬜ |
| TC-9.4 | Toggle "Hide Score" | Score counter disappears from HUD | ⬜ |

---

## Feature 10: UI - Inventory Panel

**User Story:**
As a player, I want to see which minerals I've collected, with icons and counts, so I know what I have to sort.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 10.1: Inventory Display
```gherkin
Given the player has collected:
  - 5 rubies
  - 3 sapphires
  - 1 emerald
Then the inventory panel shows:
  - [💎 Ruby x5]
  - [🔷 Sapphire x3]
  - [💚 Emerald x1]
And each entry shows the mineral icon (16x16px sprite) + count text
```

#### AC 10.2: Drag from Inventory
```gherkin
Given the inventory panel is visible
When the player clicks and holds a mineral icon
Then the icon detaches from the panel (follows cursor)
And a semi-transparent "ghost" icon remains in the panel slot
When the player drags over a bin and releases
Then the mineral is sorted (per Feature 4)
```

#### AC 10.3: Empty Inventory State
```gherkin
Given the player has no minerals in inventory
Then the inventory panel shows a message: "Break rocks to collect minerals"
And no mineral icons are displayed
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-10.1 | Collect 5 rubies, 3 sapphires | Inventory shows correct icons + counts | ⬜ |
| TC-10.2 | Drag ruby from inventory to bin | Sorting works (Feature 4) | ⬜ |
| TC-10.3 | Start new game (empty inventory) | Message "Break rocks to collect" appears | ⬜ |

---

## Feature 11: Audio - Core SFX (5 Sounds)

**User Story:**
As a player, I want satisfying sound effects for my actions, to make the game feel responsive and rewarding.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 11.1: SFX Playback
```gherkin
Given the game is running with SFX volume at 70%
When the following actions occur:
  - Rock hit → plays "thunk.wav"
  - Rock break → plays "shatter.wav"
  - Mineral collect → plays "ping.wav"
  - Correct sort → plays "clink.wav"
  - Bin complete → plays "chime.wav"
Then each sound plays within 50ms of the action
And no sound overlaps (max 8 concurrent SFX)
```

#### AC 11.2: Volume Control
```gherkin
Given the player adjusts the SFX volume slider to 40%
When a rock breaks
Then the "shatter.wav" plays at 40% volume (not 70%)
And the change applies immediately (no restart needed)
```

#### AC 11.3: No Audio Glitches
```gherkin
Given multiple rocks break simultaneously (e.g., 3 at once)
When all SFX trigger
Then no audio clipping, popping, or distortion occurs
And the audio engine limits playback to 8 concurrent sounds
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-11.1 | Break rock | "Shatter" SFX plays within 50ms | ⬜ |
| TC-11.2 | Collect mineral | "Ping" SFX plays | ⬜ |
| TC-11.3 | Complete bin | "Chime" SFX (C-E-G major) plays | ⬜ |
| TC-11.4 | Break 10 rocks at once | No audio clipping, max 8 concurrent | ⬜ |

---

## Feature 12: Music - 1 Ambient Track

**User Story:**
As a player, I want a calming background music track that loops seamlessly, to enhance the relaxing atmosphere.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 12.1: Music Playback
```gherkin
Given the game starts
When the main scene loads
Then the music track "gentle_quarry.ogg" begins playing
And the track loops seamlessly (no gap or click at loop point)
And the volume is set to 30% by default
```

#### AC 12.2: Music Volume Control
```gherkin
Given the player adjusts the Music volume slider to 50%
When the slider updates
Then the music volume increases to 50% immediately
And the music continues playing (no restart)
```

#### AC 12.3: Music Priority (Below SFX)
```gherkin
Given music is playing at 30% and SFX at 70%
When a rock breaks (SFX triggered)
Then the SFX is clearly audible over the music
And the music does not duck (volume stays constant at 30%)
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-12.1 | Start game | Music "Gentle Quarry" plays, loops seamlessly | ⬜ |
| TC-12.2 | Adjust music volume to 50% | Music volume updates immediately | ⬜ |
| TC-12.3 | Trigger SFX while music plays | SFX audible, no music ducking | ⬜ |
| TC-12.4 | Mute music | Music stops, can be unmuted | ⬜ |

---

## Feature 13: PC Controls

**User Story:**
As a PC player, I want responsive mouse and keyboard controls, so the game feels smooth and lag-free.

**Priority:** P0 (Critical Path)

### Acceptance Criteria

#### AC 13.1: Mouse Input Latency
```gherkin
Given the player clicks on a rock
When the input is processed
Then the rock responds within 50ms (visual feedback or break)
And no missed clicks occur (100% input detection)
```

#### AC 13.2: Drag Smoothness
```gherkin
Given the player drags a mineral from inventory to bin
When the drag motion occurs
Then the mineral icon follows the cursor at 60 FPS
And there is no stutter or rubber-banding
```

#### AC 13.3: Keyboard Shortcuts
```gherkin
Given the game is running
When the player presses:
  - "1" key → selects Bin 1
  - "Space" key → pauses game
  - "Esc" key → opens settings
Then each action executes within 50ms
And keyboard shortcuts are displayed in the pause menu ("Controls" tab)
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-13.1 | Click rock | Response <50ms, no missed inputs | ⬜ |
| TC-13.2 | Drag mineral | Smooth 60 FPS motion, no stutter | ⬜ |
| TC-13.3 | Press "1" key | Bin 1 selected (highlighted) | ⬜ |
| TC-13.4 | Press "Space" | Game pauses immediately | ⬜ |

---

## Feature 14: Settings Menu

**User Story:**
As a player, I want to adjust audio volumes and enable colorblind mode, to customize my experience.

**Priority:** P1 (Important)

### Acceptance Criteria

#### AC 14.1: Volume Sliders
```gherkin
Given the settings menu is open
When the player drags the "Master Volume" slider from 70% to 50%
Then all audio (SFX + Music) reduces to 50% of original volume
And the change applies immediately (no restart needed)
When the player adjusts "SFX Volume" to 80%
Then SFX plays at 80% of Master Volume (0.5 * 0.8 = 40% absolute)
```

#### AC 14.2: Colorblind Mode Toggle
```gherkin
Given the settings menu is open
When the player enables "Colorblind Mode"
Then all mineral sprites gain pattern overlays:
  - Red gems: horizontal stripes
  - Blue gems: diagonal dots
  - Green gems: vertical lines
And the patterns persist until toggled off
And the setting is saved to LocalStorage
```

#### AC 14.3: Hide Score Checkbox
```gherkin
Given the settings menu is open
When the player checks "Hide Score"
Then the score counter in the HUD disappears
And the setting is saved to LocalStorage
When the player unchecks it
Then the score counter reappears
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-14.1 | Adjust Master Volume to 50% | All audio reduces to 50% immediately | ⬜ |
| TC-14.2 | Enable Colorblind Mode | Pattern overlays appear on gems | ⬜ |
| TC-14.3 | Check "Hide Score" | Score counter disappears from HUD | ⬜ |
| TC-14.4 | Save settings, reload game | Settings persist (volumes, colorblind, hide score) | ⬜ |

---

## Feature 15: Tutorial (3 Tooltips)

**User Story:**
As a new player, I want simple hints to learn the core mechanics, without feeling overwhelmed.

**Priority:** P1 (Important)

### Acceptance Criteria

#### AC 15.1: First Launch Detection
```gherkin
Given the player launches the game for the first time
And LocalStorage does not contain a "tutorial_completed" flag
When the main scene loads
Then a tooltip appears (center screen, semi-transparent box, 300x150px)
And the tooltip reads: "Click a rock to break it!"
And a glowing arrow points to the nearest rock
```

#### AC 15.2: Sequential Tooltips
```gherkin
Given the first tooltip is displayed
When the player clicks a rock (breaking it)
Then the first tooltip fades out
And after 1 second, the second tooltip appears:
  "Move your cursor near minerals to collect them!"
And a glowing circle highlights the auto-collect radius
When the player collects a mineral
Then the second tooltip fades out
And the third tooltip appears:
  "Drag minerals to bins to sort them!"
And a glowing arrow points to a sorting bin
```

#### AC 15.3: Tutorial Completion
```gherkin
Given the player completes the third tutorial step (sorts a mineral)
When the sort action completes
Then the third tooltip fades out
And a "Tutorial Complete!" message appears (2 seconds)
And the "tutorial_completed" flag is saved to LocalStorage
And tooltips never appear again on subsequent launches
```

#### AC 15.4: Skip Option
```gherkin
Given any tutorial tooltip is displayed
When the player presses "Esc" key or clicks "Skip Tutorial" button
Then all tooltips immediately disappear
And the "tutorial_completed" flag is saved
```

### Test Cases

| Test ID | Input | Expected Output | Status |
|---------|-------|----------------|--------|
| TC-15.1 | First launch (no save) | Tooltip 1 "Click a rock" appears | ⬜ |
| TC-15.2 | Break rock | Tooltip 2 "Collect minerals" appears | ⬜ |
| TC-15.3 | Collect mineral | Tooltip 3 "Drag to bin" appears | ⬜ |
| TC-15.4 | Sort mineral | "Tutorial Complete!" appears, flag saved | ⬜ |
| TC-15.5 | Press "Esc" during tooltip | Tutorial skipped, flag saved | ⬜ |
| TC-15.6 | Launch game again | No tooltips (tutorial completed) | ⬜ |

---

## Summary Checklist

**All 15 MVP features must pass acceptance tests before release.**

| Feature ID | Feature Name | Status | Notes |
|------------|--------------|--------|-------|
| 1 | Rock Breaking | ⬜ | — |
| 2 | Mineral Spawning | ⬜ | — |
| 3 | Auto-Collection | ⬜ | — |
| 4 | Sorting Bins (2 Types) | ⬜ | — |
| 5 | Bin Completion Reward | ⬜ | — |
| 6 | Score System | ⬜ | — |
| 7 | Progression Tier 1 | ⬜ | — |
| 8 | Save/Load System | ⬜ | — |
| 9 | UI: HUD | ⬜ | — |
| 10 | UI: Inventory Panel | ⬜ | — |
| 11 | Audio: Core SFX | ⬜ | — |
| 12 | Music: 1 Ambient Track | ⬜ | — |
| 13 | PC Controls | ⬜ | — |
| 14 | Settings Menu | ⬜ | — |
| 15 | Tutorial (3 Tooltips) | ⬜ | — |

---

**Legend:**
⬜ Not Started | 🟡 In Progress | ✅ Passed | ❌ Failed

**Sign-Off:**
QA Lead: _____________
Product Owner: _____________
Date: _____________
