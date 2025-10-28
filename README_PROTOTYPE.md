# Order Game - Core Loop Prototype

**Version:** Prototype v0.2 (Enhanced)
**Date:** 2025-10-28
**Branch:** `claude/proto-core-loop-011CUXTE81tUisGNiqWMCoR8`
**Engine:** Godot 4.3+

## Overview

This is a minimal playable prototype of the **Order Game** core loop:
1. **Break rocks** by clicking them
2. **Collect minerals** that scatter with physics (auto-collect within 100px of cursor)
3. **Sort minerals** into bins by color (click bin to sort first matching mineral)
4. **Earn points** and watch your score grow

**Target:** Demonstrate core game feel (relaxing, satisfying, no pressure).

---

## How to Run

### Prerequisites

- **Godot 4.3+** installed ([Download](https://godotengine.org/download))
- This repository cloned

### Steps

1. Open Godot 4.3+ Project Manager
2. Click **Import**
3. Navigate to `/home/user/order_game` (or your clone path)
4. Select `project.godot`
5. Click **Import & Edit**
6. Wait for project to load (may take 10-30s for first import)
7. Press **F5** or click **Run** button (▶️ Play icon)

**Expected result:** Game window opens at 1920x1080, you see 1 gray rock in the center.

---

## Controls (PC)

| Action | Input | Description |
|--------|-------|-------------|
| **Break Rock** | Left Click on rock | Reduces rock HP, breaks when HP reaches 0 |
| **Collect Minerals** | Move cursor near minerals | Auto-collects minerals within 100px radius |
| **Sort Mineral (Drag)** | Drag from inventory, drop on bin | **NEW!** Full drag-drop sorting (v0.2) |
| **Sort Mineral (Button)** | Click "Red Bin" or "Blue Bin" button | Fallback method, sorts first matching mineral |
| **Settings** | Escape (ESC) | **NEW!** Opens settings menu with volume controls (v0.2) |

---

## Expected Behavior (Acceptance Criteria)

### ✅ Feature 1: Rock Breaking (AC 1.1, 1.2)

**Test:**
1. Click on the gray rock (Stone Rock, HP=1) in the center
2. **Expected:** Rock flashes white, then shatters immediately
3. **Expected:** 5-10 colored squares (minerals) spawn and scatter with physics

**Test (Multi-HP):**
1. If a darker rock (Granite Rock, HP=2) spawns
2. Click it once → rock darkens (visual crack feedback)
3. Click again → rock shatters

**Status:** ✅ Implemented

---

### ✅ Feature 2: Mineral Spawning (AC 2.1, 2.2, 2.3)

**Test:**
1. Break a rock
2. **Expected:** Minerals scatter in ±45° arc, bounce once on ground, settle within 3 seconds
3. **Expected:** ~70% common minerals (red/blue), ~25% uncommon (green), ~5% rare (yellow/purple)
4. **Expected:** Each mineral fades in smoothly (0.15s alpha tween)

**Colors:**
- Red = Ruby (common)
- Blue = Sapphire (common)
- Green = Emerald (uncommon)
- Yellow = Topaz (rare)
- Purple = Amethyst (rare)
- White = Diamond (epic, very rare)

**Status:** ✅ Implemented

---

### ✅ Feature 3: Auto-Collection (AC 3.1, 3.3)

**Test:**
1. Wait for minerals to settle (stop bouncing)
2. Move your cursor near a resting mineral (within ~100px)
3. **Expected:** Mineral flies toward cursor in smooth arc (0.3s), then disappears
4. **Expected:** Inventory panel (bottom of screen) updates: "Ruby Shard ×1" (or similar)

**Note:** Only **resting** minerals can be collected (bouncing ones are ignored).

**Status:** ✅ Implemented

---

### ✅ Feature 4: Sorting Bins (AC 4.1) - **v0.2 ENHANCED**

**Test (Drag-Drop):** *(NEW in v0.2)*
1. Collect at least 1 red mineral (Ruby) and 1 blue mineral (Sapphire)
2. Check inventory panel shows both: e.g., "[#E57373] Ruby Shard ×3"
3. **Click and hold** on the Ruby item in inventory
4. **Drag** toward the **"Red Bin (0/10)"**
5. **Release** mouse button over the bin
6. **Expected:** Bin flashes green, Ruby removed from inventory, bin updates to "Red Bin (1/10)"
7. **Expected:** Score increases by +10, "sort_correct" sound plays (if audio files present)

**Test (Drag-Drop Mismatch):**
1. Drag a blue mineral over Red Bin
2. **Expected:** Cursor shows "not allowed" (no drop occurs)
3. Release → nothing happens, mineral stays in inventory

**Test (Button Fallback):**
1. Click the **"Red Bin (0/10)"** button
2. **Expected:** First red mineral from inventory is sorted (same as drag-drop)

**Test (Bin Complete):**
1. Sort 10 red minerals into Red Bin (via drag or button)
2. **Expected:** Bin shows "Red Bin (10/10)"
3. **Expected:** +50 bonus points awarded, "bin_complete" sound plays
4. **Expected:** Game auto-saves (check console: "[SaveSystem] Saved game...")
5. **Expected:** After 1 second, bin resets to "Red Bin (0/10)"

**Status:** ✅ Fully Implemented (v0.2 - includes full drag-drop + visual feedback)

---

### ✅ Feature 5: Score System (AC 6.1, 6.3)

**Test:**
1. Break 1 rock → +5 points
2. Collect 1 ruby → +10 points (common mineral)
3. Sort 1 ruby → +10 points
4. Complete 1 bin (10 minerals) → +50 bonus
5. **Total example:** Break 1 rock + collect 10 rubies + sort 10 rubies = 5 + 100 + 100 + 50 = **255 points**

**Test (Combo):**
1. Sort 5 minerals correctly in a row (any color/bin)
2. **Expected:** After 5th sort, "+25 SMOOTH OPERATOR" bonus appears in HUD
3. Combo counter resets to 0

**Status:** ✅ Implemented

---

### ✅ Feature 6: Audio System (AC 5.1) - **v0.2 NEW**

**Test:**
1. Break a rock → **Expected:** "rock_break.wav" plays (if audio file present)
2. Collect a mineral → **Expected:** "mineral_collect.wav" plays
3. Sort a mineral → **Expected:** "sort_correct.wav" plays
4. Complete a bin → **Expected:** "bin_complete.wav" plays
5. Trigger 5-combo → **Expected:** "combo.wav" plays
6. Game starts → **Expected:** "bgm_ambient.ogg" loops (background music)

**How to Add Audio Files:**
1. Create `audio/sfx/` and `audio/music/` directories (already created)
2. Add 5 SFX files and 1 music file (see `audio/AUDIO_PLACEHOLDER.md` for specs)
3. Restart game → audio plays automatically

**Status:** ✅ System Implemented (awaiting audio files - game functions silently without them)

---

### ✅ Feature 7: Pixel Art Sprites (AC 8.1) - **v0.2 NEW**

**Test:**
1. Add `sprites/rocks/stone_rock.png` (32x32 pixel art)
2. Add `sprites/minerals/ruby_small.png` (16x16 pixel art)
3. Restart game → **Expected:** Sprites replace ColorRect placeholders

**How to Add Sprites:**
- See `sprites/SPRITES_PLACEHOLDER.md` for detailed specifications
- Rocks: 32x32 PNG, minerals: 16x16 PNG
- Colorblind-friendly (ruby=triangle, sapphire=square, emerald=circle)

**Fallback:** If no PNG files present, game uses ColorRect placeholders (current state)

**Status:** ✅ System Implemented (awaiting pixel art - game uses ColorRect fallback)

---

### ✅ Feature 8: Settings Menu (AC 7.1-7.3) - **v0.2 NEW**

**Test:**
1. Press **ESC** key → **Expected:** Settings menu opens, game pauses
2. Adjust "Master Volume" slider → **Expected:** Audio volume changes in real-time
3. Adjust "SFX Volume" slider → **Expected:** Test sound plays ("mineral_collect")
4. Adjust "Music Volume" slider → **Expected:** Background music volume changes
5. Toggle "Colorblind Mode" → **Expected:** Setting saved (visual changes not implemented yet)
6. Press **ESC** again or click "Close" → **Expected:** Menu closes, game resumes, settings auto-saved

**Saved Settings:**
- All volume levels persist between sessions
- Colorblind mode preference saved to `user://save_data.json`

**Status:** ✅ Fully Implemented (v0.2)

---

### ✅ Feature 9: Save System (AC 9.1-9.3) - **v0.2 NEW**

**Test:**
1. Play game, earn 500 points, break 10 rocks, sort 50 minerals
2. Complete a bin → **Expected:** Console shows "[SaveSystem] Saved game..."
3. Close game, reopen → **Expected:** High score persists (shown in console on load)
4. Open settings → **Expected:** Volume sliders match saved values

**What Gets Saved:**
- **Settings:** Master/SFX/Music volume, Colorblind mode
- **Progress:** High score, total rocks broken, total minerals sorted, total combos
- **Location:** `user://save_data.json` (OS-specific Godot user data directory)

**Auto-Save Triggers:**
- Bin complete (10/10 sorted)
- Settings menu closed
- Manual: `SaveSystem.save_game()` called

**Status:** ✅ Fully Implemented (v0.2)

---

## UI Layout

```
┌─────────────────────────────────────────────────────────┐
│                                       Score: 1250       │ ← HUD (top-right)
│                                       Combo: 3          │
│                                                         │
│                                                         │
│            ▓▓▓ ROCK ▓▓▓      • • Minerals • •          │ ← Playfield (center)
│                                                         │
│                                                         │
│─────────────────────────────────────────────────────────│
│  INVENTORY                                              │ ← Inventory (bottom)
│  [#E57373] Ruby Shard  ×5                               │
│  [#64B5F6] Sapphire  ×3                                 │
│─────────────────────────────────────────────────────────│
│          [Red Bin (5/10)]  [Blue Bin (3/10)]            │ ← Sorting Bins (above inventory)
└─────────────────────────────────────────────────────────┘
```

---

## Known Limitations (Prototype v0.2)

1. ~~**No drag-and-drop sorting**~~ ✅ **FIXED in v0.2**: Full drag-drop implemented
2. **No audio files**: Audio *system* implemented, but requires WAV/OGG files to be added (see `audio/AUDIO_PLACEHOLDER.md`)
3. ~~**No settings menu**~~ ✅ **FIXED in v0.2**: Settings accessible via ESC, includes volume controls
4. ~~**No save system**~~ ✅ **FIXED in v0.2**: Auto-save on bin complete, persists high score & settings
5. **No pixel art**: Sprite *system* implemented, but requires PNG files to be added (see `sprites/SPRITES_PLACEHOLDER.md`). Currently uses ColorRect placeholders.
6. **Auto-respawn rocks**: Rocks respawn automatically every 1 second for testing (not final behavior).
7. **No mobile controls**: PC mouse/keyboard only (touchscreen not implemented yet).
8. **Colorblind mode visual**: Setting saves, but visual enhancements (shape outlines, patterns) not implemented yet.

---

## Architecture Notes

### Singletons (AutoLoad)

- **DataLoader**: Loads `data/minerals.json` and `data/rocks.json` at startup
- **InventoryManager**: Tracks collected mineral counts, emits `inventory_changed` signal
- **ScoreManager**: Tracks score and combo, emits `score_changed` and `combo_triggered` signals, saves high score
- **AudioManager**: *(v0.2 NEW)* Manages all audio playback (5 SFX + 1 music), volume controls
- **SaveSystem**: *(v0.2 NEW)* Handles persistent data (settings, high score, stats), auto-saves to `user://save_data.json`

### Key Scenes

- **Main.tscn**: Root scene, spawns rocks, handles core loop orchestration, starts background music
- **Rock.tscn**: StaticBody2D with HP, clickable, emits `rock_broken` signal, supports sprite + ColorRect fallback
- **Mineral.tscn**: RigidBody2D with physics, auto-detects resting state, supports sprite + ColorRect fallback
- **CollectionZone.tscn**: Area2D (100px radius) that follows cursor, collects resting minerals
- **SortingBin.tscn**: *(v0.2 ENHANCED)* Drag-drop target with `_can_drop_data()` + `_drop_data()`, visual feedback (green flash)
- **UI/HUD.tscn**: Score + combo display (top-right)
- **UI/InventoryPanel.tscn**: *(v0.2 ENHANCED)* Lists minerals with draggable items (`_get_drag_data()`)
- **UI/SettingsMenu.tscn**: *(v0.2 NEW)* ESC-triggered menu, volume sliders, colorblind toggle, pauses game

### Data-Driven Content

Edit `data/minerals.json` or `data/rocks.json` to add new content **without changing code**:

**Example: Add new mineral**
```json
{
  "id": "obsidian_shard",
  "name": "Obsidian",
  "shape": "triangle",
  "color": "black",
  "rarity": "rare",
  "points": 50,
  "color_hex": "#212121"
}
```

Add to `data/rocks.json` loot table → restart game → new mineral appears!

---

## Troubleshooting

### Issue: Rock doesn't break when clicked
- **Check:** Is CollisionShape2D active in Rock.tscn?
- **Check:** Console output (should show "[Main] Rock broken: ...")

### Issue: Minerals don't collect
- **Check:** Move cursor **slowly** near resting minerals (wait ~3s for physics to settle)
- **Check:** Console output (should show "[InventoryManager] Added 1 × ruby_small")

### Issue: Sorting bins don't work
- **Check:** Do you have matching minerals in inventory? (Check inventory panel)
- **Check:** Console output (should show "[SortingBin] Sorted ruby_small to red bin")

### Issue: Score doesn't update
- **Check:** HUD.tscn is added to Main.tscn under UI CanvasLayer
- **Check:** Console output (should show "[ScoreManager] +10 points")

---

## Testing Checklist (Manual QA)

- [ ] T1: Launch game → 1 rock spawns at center
- [ ] T2: Click rock → shatters, 5-10 minerals spawn
- [ ] T3: Move cursor near minerals → auto-collect, inventory updates
- [ ] T4: Inventory panel shows mineral counts (e.g., "Ruby Shard ×3")
- [ ] T5: Click Red Bin → removes 1 ruby, score +10
- [ ] T6: Fill Red Bin to 10/10 → +50 bonus, bin resets after 1s
- [ ] T7: Sort 5 minerals in a row → "COMBO! +25" appears
- [ ] T8: Break 3 different rocks → new rocks respawn automatically

---

## Next Steps (Post-Prototype v0.2)

### ✅ COMPLETED in v0.2:
1. ~~**Full drag-and-drop sorting**~~ → Implemented with `_get_drag_data()` / `_can_drop_data()`
2. ~~**Audio integration**~~ → System ready, awaiting 5 SFX + 1 music file
3. ~~**Visual polish**~~ → Sprite system ready, awaiting pixel art PNG files
4. ~~**Settings menu**~~ → ESC-triggered, volume sliders, colorblind toggle
5. ~~**Save system**~~ → Auto-save on bin complete, restores on launch

### 🎯 TODO for Production MVP:
6. **Add actual audio files**: Create/source 5 SFX + 1 music track (see `audio/AUDIO_PLACEHOLDER.md`)
7. **Add actual pixel art**: Create/source 2 rock sprites + 6 mineral sprites (see `sprites/SPRITES_PLACEHOLDER.md`)
8. **Colorblind mode visuals**: Implement shape outlines, patterns, or increased contrast
9. **Mobile controls**: Touch + haptics, gesture-based sorting
10. **Progression system**: Unlock Tier 1 (Granite Rock, +3 minerals) at 20 rocks broken
11. **Tutorial**: First-time user guidance (arrows, tooltips)
12. **Juice & Polish**: Particle effects (rock shatter, sparkles), screen shake, more animations

---

## Feedback

For bugs or questions, please:
- Check Console Output (Godot → Output tab at bottom)
- Review `docs/mvp-acceptance-criteria.md` for expected behavior
- Contact: [Your contact info or GitHub issues link]

---

**Enjoy breaking rocks and sorting minerals! 🪨💎**
