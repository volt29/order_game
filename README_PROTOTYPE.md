# Order Game - Core Loop Prototype

**Version:** Prototype v0.1
**Date:** 2025-10-27
**Branch:** `proto/core-loop`
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
| **Sort Mineral** | Click "Red Bin" or "Blue Bin" button | Sorts first matching mineral from inventory |
| **Pause** | Space | *(Not implemented yet)* |
| **Settings** | Escape | *(Not implemented yet)* |

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

### ✅ Feature 4: Sorting Bins (AC 4.1, simplified)

**Test:**
1. Collect at least 1 red mineral (Ruby) and 1 blue mineral (Sapphire)
2. Check inventory panel shows both: e.g., "Ruby Shard ×3", "Sapphire ×2"
3. Click the **"Red Bin (0/10)"** button
4. **Expected:** First red mineral from inventory is removed, bin updates to "Red Bin (1/10)"
5. **Expected:** Score increases by +10 (shown in top-right HUD)

**Test (Mismatch - implicit):**
- If you have only blue minerals and click Red Bin → nothing happens (no matching minerals)

**Test (Bin Complete):**
1. Sort 10 red minerals into Red Bin
2. **Expected:** Bin shows "Red Bin (10/10)"
3. **Expected:** +50 bonus points awarded
4. **Expected:** After 1 second, bin resets to "Red Bin (0/10)"

**Status:** ✅ Implemented (placeholder: click bin button instead of drag-drop)

**Note:** Full drag-and-drop interaction is **not implemented yet**. Current version uses button click as a simplified alternative for prototype testing.

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

## Known Limitations (Prototype)

1. **No drag-and-drop sorting**: Click bin button to sort first matching mineral (simplified for prototype).
2. **No audio**: Placeholder only (SFX/music not implemented).
3. **No settings menu**: Pause/Esc not functional.
4. **No save system**: Progress resets on game close.
5. **Limited visual polish**: ColorRect placeholders instead of pixel art sprites.
6. **Auto-respawn rocks**: Rocks respawn automatically every 1 second for testing (not final behavior).
7. **No mobile controls**: PC mouse/keyboard only.

---

## Architecture Notes

### Singletons (AutoLoad)

- **DataLoader**: Loads `data/minerals.json` and `data/rocks.json` at startup
- **InventoryManager**: Tracks collected mineral counts, emits `inventory_changed` signal
- **ScoreManager**: Tracks score and combo, emits `score_changed` and `combo_triggered` signals

### Key Scenes

- **Main.tscn**: Root scene, spawns rocks, handles core loop orchestration
- **Rock.tscn**: StaticBody2D with HP, clickable, emits `rock_broken` signal
- **Mineral.tscn**: RigidBody2D with physics, auto-detects resting state
- **CollectionZone.tscn**: Area2D (100px radius) that follows cursor, collects resting minerals
- **SortingBin.tscn**: UI button with validation logic (checks mineral color/shape)
- **UI/HUD.tscn**: Score + combo display (top-right)
- **UI/InventoryPanel.tscn**: Lists collected minerals with counts (bottom)

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

## Next Steps (Post-Prototype)

1. **Full drag-and-drop sorting**: Replace button click with `_get_drag_data()` / `_can_drop_data()` Godot API
2. **Audio integration**: Add 5 core SFX + 1 ambient music track
3. **Visual polish**: Replace ColorRect with pixel art sprites (16x16, 32x32)
4. **Settings menu**: Pause, volume sliders, colorblind mode toggle
5. **Save system**: Auto-save on bin complete, restore on launch
6. **Mobile controls**: Touch + haptics, gesture-based sorting
7. **Progression system**: Unlock Tier 1 (Granite Rock, +3 minerals) at 20 rocks broken

---

## Feedback

For bugs or questions, please:
- Check Console Output (Godot → Output tab at bottom)
- Review `docs/mvp-acceptance-criteria.md` for expected behavior
- Contact: [Your contact info or GitHub issues link]

---

**Enjoy breaking rocks and sorting minerals! 🪨💎**
