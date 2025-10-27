# Order Game — Game Design Document (MVP)

**Version:** 1.0
**Date:** 2025-10-27
**Target Platforms:** PC (primary) → Mobile (future)
**Genre:** Relaxing puzzle, zen mining, sorting simulator
**Session Length:** 3–8 minutes

---

## 1. Pitch

**Order Game** is a meditative 2D pixel-art experience where players break colorful rocks to collect shimmering minerals, then sort them at their own pace. Designed for busy adults seeking calm and closure, the game delivers satisfying "tidy-up" moments without timers or penalties. Every action—cracking stone, hearing gems clink into place, watching progress bars fill—reinforces a gentle sense of accomplishment. Perfect for short breaks, commutes, or bedtime wind-downs. **Keywords:** Mindful, Cozy, Organizer's Delight, Non-competitive, Visual ASMR, Comfort Gaming.

*(Word count: 78)*

---

## 2. Core Loop

### Flow Diagram

```
     ┌──────────────────────────────────────────────┐
     │                                              │
     ▼                                              │
 ╔═══════════════╗      ╔═══════════════╗      ╔═══════════════╗
 ║   DESTROY     ║  →→  ║    COLLECT    ║  →→  ║     SORT      ║
 ║  Rock/Stone   ║      ║   Minerals    ║      ║  By Criteria  ║
 ╚═══════════════╝      ╚═══════════════╝      ╚═══════════════╝
      ↑                      ↓ ↓ ↓                    ↓
      │               Physics scatter                 │
      │               particles fall              Earn points
      │                                          Unlock tools
      │                                                │
      └────────────────────────────────────────────────┘
                    Repeat with new rocks
```

### Description

1. **Destroy:** Player clicks/taps a rock. It fractures with satisfying visual/audio feedback, releasing 5-15 mineral particles.
2. **Collect:** Minerals scatter across the playfield, bouncing gently. Player collects them (auto-collect area or manual tap).
3. **Sort:** Player drags minerals into sorting bins (by color, shape, rarity, or custom criteria). Completing a bin yields points and a "closure chime."
4. **Repeat:** New rocks appear. Player unlocks better tools (faster breaking, larger bins) and new biomes/rock types.

**No fail state.** No timers. Pure flow, pure satisfaction.

---

## 3. Systems and Mechanics

### 3.1 Destruction and Physics

**Destruction:**
- **Input:** Click (PC) / Tap (Mobile) on rock sprite.
- **Durability:** Rocks have 1-5 "health points" (HP). Each hit reduces HP by 1. Visual cracks appear.
- **Break Feedback:** Screen shake (subtle), particle burst, satisfying "crunch" SFX, rock sprite shatters into 3-6 large fragments that fade away.

**Physics Scatter:**
- Minerals spawn at break point with random velocity vectors (2D physics).
- Gentle gravity pulls them down; slight friction slows horizontal motion.
- Particles settle within 1-3 seconds into a "resting" state (ready to collect).
- **Budget:** Max 50 minerals on-screen simultaneously (see Performance Budget).

**Collision:**
- Minerals collide with ground and walls (bounce once, low elasticity).
- No mineral-to-mineral collision (performance).

### 3.2 Mineral Generation and Taxonomy

**Taxonomy (Data-Driven):**

Minerals defined in `minerals.json` config file:

```json
{
  "mineralTypes": [
    {
      "id": "ruby_small",
      "displayName": "Ruby Shard",
      "shape": "triangle",
      "color": "red",
      "rarity": "common",
      "pointValue": 10,
      "spriteSheet": "gems_atlas.png",
      "spriteIndex": 0
    }
  ]
}
```

**Attributes:**
- **Shape:** circle, triangle, square, hexagon, star (5 base shapes in MVP).
- **Color:** red, blue, green, yellow, purple, white (6 colors, colorblind-safe palette).
- **Rarity:** common (70%), uncommon (20%), rare (9%), epic (1%).
- **Size:** small, medium, large (visual only, no gameplay impact in MVP).

**Generation Logic:**
- When rock breaks, game rolls random minerals from a **loot table** (per biome/rock type).
- Each rock type has weighted probabilities (e.g., "Stone Rock" → 60% common, 30% uncommon, 10% rare).
- Future: Seasonal events modify loot tables (data patch, no code change).

### 3.3 Collection and Sorting

**Collection:**
- **Auto-Collect Zone (PC/Mobile):** Minerals within 100px radius of cursor/finger auto-fly toward collection bag (smooth lerp animation).
- **Manual Tap (Mobile):** Tap individual mineral to collect.
- **Feedback:** Gentle "ping" sound, mineral fades with trail effect, counter updates (+1 Ruby).

**Sorting:**
- **Sorting Area:** Bottom third of screen shows 3-6 **sorting bins** (labeled: "Red Gems," "Blue Gems," "All Triangles," etc.).
- **Drag & Drop (PC):** Click mineral in inventory panel, drag to bin, release. If criteria match → mineral locks in with satisfying "clink." If mismatch → mineral bounces back with error buzz.
- **Tap to Sort (Mobile):** Select mineral, then tap bin. Same feedback.
- **Custom Bins:** Player can toggle bin criteria (shape, color, rarity). Unlocked progressively.
- **Completion:** When bin reaches capacity (e.g., 10/10 rubies), triggers:
  - Visual: Sparkling effect, bin glows.
  - Audio: Harmonious chime (reward).
  - Points: Bonus multiplier for "clean sort."

**Semi-Auto Sorting (Zen Mode Unlock):**
- Late-game tool: "Auto-Sorter Hint" highlights correct bin for selected mineral (no penalty for ignoring).

### 3.4 Scoring System (Relax-First)

**Philosophy:** Points are **positive feedback**, never punitive.

**Point Sources:**
- **Breaking Rocks:** +5 points per rock (flat reward for engagement).
- **Collecting Minerals:** +10 points per common, +20 uncommon, +50 rare, +100 epic.
- **Sorting Correctly:** +10 bonus per correct sort.
- **Completing Bin:** +50 bonus + 2x multiplier for next bin if completed without errors.
- **Combo (Non-Punishing):** Sorting 5 minerals in a row without mismatch → gentle +25 bonus and "Smooth Operator" text pop. Combo resets on mismatch (no penalty, just no bonus).

**No Penalties For:**
- Slow play.
- Mis-sorting (just bounces back).
- Leaving minerals uncollected.

**Display:** Small, unobtrusive score counter (top-right). Optional toggle: "Hide Score" for pure zen.

### 3.5 Progression (Comfort-First)

**Unlock Tiers (Session-Based):**

| Tier | Unlock Trigger | New Content |
|------|----------------|-------------|
| **Tier 0** (Start) | — | Stone Rock (1 HP), 3 mineral types, 2 sorting bins |
| **Tier 1** | Break 20 rocks | Granite Rock (2 HP), +3 mineral types (blue, yellow gems), +1 bin |
| **Tier 2** | Sort 100 minerals | Pickaxe tool (break rocks in 1 hit), +2 rare minerals, custom bin |
| **Tier 3** | Complete 10 bins | Marble Rock (3 HP), new biome (Forest), gentle background music track 2 |
| **Tier 4** | 1 hour playtime | Zen Mode (auto-sorter hints, hide score), +1 epic mineral, larger bins |

**Biomes (Visual Variety):**
- **Starter Biome (Quarry):** Gray rocks, neutral palette, calm ambient sound.
- **Forest Biome:** Mossy rocks, green tones, bird chirps.
- **Cave Biome (Post-MVP):** Crystalized rocks, glowing minerals, echo SFX.

**Progression Pace:** ~10 minutes to Tier 1, ~30 min to Tier 2, ~1 hour to Tier 3. No grind. Organic unlock cadence.

**Save System:** Auto-save after each completed bin. LocalStorage (web) / PlayerPrefs (standalone).

---

## 4. UX/UI and Controls

### 4.1 PC (Mouse + Keyboard)

**Mouse:**
- **Left Click:** Break rock (hold to repeat if multi-HP rock).
- **Click + Drag:** Drag mineral from inventory to sorting bin.
- **Right Click (Optional):** Quick-info tooltip on mineral (shows type, rarity).

**Keyboard Shortcuts (Quality of Life):**
- **1-6 Keys:** Select sorting bin 1-6 (then click mineral to auto-sort).
- **Space:** Pause / Resume (freeze physics, open pause menu).
- **Tab:** Cycle through minerals in inventory.
- **Z:** Undo last sort (1-level undo buffer).
- **Escape:** Open settings (volume, colorblind mode, hide score).

**UI Layout (PC):**
```
┌───────────────────────────────────────────────────────┐
│  [Score: 1250]         PLAYFIELD         [⚙ Settings] │
│                     (rocks + particles)                │
│                                                        │
│            ▓▓▓ Rock ▓▓▓       • • Minerals • •        │
│                                                        │
│────────────────────────────────────────────────────────│
│  INVENTORY: [💎5] [🔷3] [⭐1]  (collected minerals)     │
│────────────────────────────────────────────────────────│
│  BINS: [Red|10/10✓] [Blue|3/10] [Triangles|7/15] ...  │
└────────────────────────────────────────────────────────┘
```

### 4.2 Mobile (Touch + Haptics)

**Touch Gestures:**
- **Tap Rock:** Break rock. Haptic feedback (light "thud" vibration).
- **Tap Mineral:** Collect it (if not auto-collected).
- **Drag Mineral to Bin:** Same as PC drag-and-drop.
- **Two-Finger Swipe Up:** Open pause menu.
- **Pinch (Optional Post-MVP):** Zoom playfield.

**Haptics Strategy:**
- **Break Rock:** Medium impact (200ms).
- **Correct Sort:** Light "success" pulse (50ms).
- **Bin Complete:** Strong "celebration" burst (300ms).
- **Mismatch:** Gentle error buzz (100ms, low intensity to avoid stress).

**Ergonomics (One-Handed Play):**
- UI elements reachable with thumb (bottom 60% of screen).
- Sorting bins at bottom edge.
- Rocks spawn in middle/top (break with upward thumb stretch, but not required continuously).

**UI Layout (Mobile - Portrait):**
```
┌─────────────────────┐
│    [Score: 1250]    │  ← Top 10% (non-interactive info)
├─────────────────────┤
│                     │
│    ▓▓▓ Rocks ▓▓▓    │  ← Middle 40% (playfield)
│      • Minerals •   │
│                     │
├─────────────────────┤
│ INV: [💎5][🔷3][⭐1] │  ← 20% (inventory strip)
├─────────────────────┤
│ BINS: [Red][Blue]   │  ← Bottom 30% (sorting bins, thumb zone)
│       [Triangle]    │
└─────────────────────┘
```

### 4.3 Minimal HUD & Zen Mode

**Minimal HUD:**
- Hide score counter (optional toggle).
- No timers, no health bars, no energy systems.
- Only essential info: current bin progress (e.g., "7/10 Red Gems").

**Zen Mode (Unlockable):**
- Auto-sorter hints (highlights correct bin when mineral selected).
- Slower particle scatter (more time to appreciate visuals).
- Optional: Guided meditation prompts ("Take a breath. No rush.").

**Non-Intrusive Hints:**
- First-time tutorial: 3 pop-up tooltips (tap rock → collect → sort). Dismissable.
- Contextual hints appear only once (e.g., "Try sorting by shape!" when unlocking custom bin).

---

## 5. Art and Sound Direction

### 5.1 Art Style: 2D Pixel Art

**Visual Aesthetic:**
- **Pixel Resolution:** 16x16 or 32x32 base sprites (scale 2x-4x for modern displays).
- **Mood:** Cozy, soft, slightly stylized (not hyper-realistic). Think *Stardew Valley* meets *A Short Hike*.
- **Animation:** Gentle idle sway for rocks, particle sparkle twinkle, smooth bin fill animations.

**Color Palette (Colorblind-Safe):**

Base palette uses high contrast + distinct hues:

| Color Name | Hex Code | Use Case | Colorblind Note |
|------------|----------|----------|-----------------|
| Soft Red | `#E57373` | Rubies, warm gems | Distinguishable from green |
| Ocean Blue | `#64B5F6` | Sapphires, water gems | High contrast |
| Forest Green | `#81C784` | Emeralds, nature gems | Safe with red/blue |
| Sunny Yellow | `#FFD54F` | Topazes, rare drops | High luminance |
| Royal Purple | `#BA68C8` | Amethysts, epic gems | Unique hue |
| Pearl White | `#EEEEEE` | Diamonds, ultra-rare | High contrast |
| UI Gray | `#424242` | Bins, backgrounds | Neutral |
| Accent Cream | `#FFF8E1` | Highlights, text | Warm neutral |

**Colorblind Mode (Settings):**
- Adds shape/pattern overlays to gems (stripes for red, dots for blue, etc.).
- Tested with Deuteranopia and Protanopia simulators.

**Rock Sprites:**
- **Stone Rock:** Gray, blocky, simple cracks.
- **Granite Rock:** Speckled texture, darker gray.
- **Marble Rock:** White with gray veins, polished look.

**Biome Backgrounds:**
- **Quarry:** Flat horizon line, neutral sky gradient (light gray → white).
- **Forest:** Parallax trees (2 layers), dappled sunlight, gentle leaf particles.
- **Cave (Post-MVP):** Stalactites, glowing crystals, darker ambiance.

### 5.2 Sound and Music

**Sound Effects (SFX):**

| Action | SFX Description | Reference |
|--------|----------------|-----------|
| **Rock Hit** | Soft "thunk" (mallet on stone) | Organic, not harsh |
| **Rock Break** | Crystalline shatter, mid-pitch "crrsh" | Satisfying crack |
| **Mineral Collect** | Gentle "ping" (glass chime) | Light, musical |
| **Correct Sort** | Warm "clink" (gem into box) | Positive reinforcement |
| **Bin Complete** | Harmonious 3-note chime (C-E-G major) | Rewarding, uplifting |
| **Mismatch** | Soft "boop" (error, not jarring) | Low stress |
| **Ambient Loop** | Subtle wind/water (biome-specific) | 20s loop, low volume |

**Music Tracks:**

| Track Name | BPM | Mood | Usage |
|------------|-----|------|-------|
| **"Gentle Quarry"** | 60 | Calm, neutral | Starter biome, main loop |
| **"Forest Whispers"** | 55 | Serene, nature | Forest biome unlock |
| **"Cave Echoes"** (Post-MVP) | 50 | Mysterious, tranquil | Cave biome |
| **Zen Mode Track** | 45 | Meditative, minimal | Zen Mode toggle |

**Music Style:**
- Ambient, lo-fi, minimal piano/synth.
- No percussion (too energizing).
- Layered pads, soft strings, occasional music box.
- Reference: *Animal Crossing*, *Unpacking*, *Townscaper* soundtracks.

**Audio Mix:**
- SFX: 70% volume.
- Music: 30% volume (player-adjustable).
- SFX always audible over music.

**Accessibility:**
- Volume sliders (Master, SFX, Music).
- Mute toggle.
- Visual feedback duplicates audio cues (particle effects for breaks, glow for bin complete).

---

## 6. Technology and Scalability

### 6.1 Recommended Engine: Godot 4.x

**Rationale:**

| Criterion | Godot 4.3+ | Alternatives |
|-----------|------------|--------------|
| **2D Workflow** | Excellent (native 2D engine, optimized) | Unity (heavier), GameMaker (less flexible) |
| **Cross-Platform Export** | PC (Windows/Mac/Linux) + Web + Android/iOS | Unity (✓), Unreal (overkill) |
| **Licensing** | Open-source, no royalties | Unity (revenue share), Unreal (5% gross) |
| **Scripting** | GDScript (Python-like, fast iteration) | C# supported (optional) |
| **Data-Driven Design** | JSON import via `load()`, resource system | ✓ |
| **Performance (2D)** | Lightweight, 60 FPS easy on mid-range devices | ✓ |
| **Community/Assets** | Growing, good 2D asset packs | Unity larger, but less 2D-focused |

**Decision:** Godot 4.3 for MVP. Re-evaluate if mobile performance issues arise (unlikely for 2D pixel art).

### 6.2 Modular Architecture

**Core Modules (Scenes/Scripts):**

```
order_game/
├── project.godot
├── scenes/
│   ├── Main.tscn              # Root scene (manages game state)
│   ├── Playfield.tscn         # Rock spawning, particle physics
│   ├── RockBreaker.tscn       # Handles click/tap on rocks
│   ├── MineralSpawner.tscn    # Loot generation, physics scatter
│   ├── CollectionZone.tscn    # Auto-collect area logic
│   ├── SortingSystem.tscn     # Bins, drag-drop validation
│   ├── ProgressionManager.tscn# Unlock tracking, save/load
│   └── UI/
│       ├── HUD.tscn           # Score, settings button
│       ├── InventoryPanel.tscn# Shows collected minerals
│       └── BinUI.tscn         # Sorting bin visual + logic
├── scripts/
│   ├── Rock.gd                # Rock HP, break logic
│   ├── Mineral.gd             # Mineral data (type, color, shape)
│   ├── SortingBin.gd          # Bin criteria, validation
│   ├── ScoreManager.gd        # Points calculation, combo
│   ├── SaveSystem.gd          # LocalStorage read/write
│   └── DataLoader.gd          # Loads minerals.json, rocks.json
├── data/
│   ├── minerals.json          # Mineral definitions
│   ├── rocks.json             # Rock types, loot tables
│   ├── biomes.json            # Biome configs (future)
│   └── progression.json       # Unlock tiers
└── assets/
    ├── sprites/
    │   ├── rocks/
    │   ├── minerals/
    │   └── ui/
    ├── audio/
    │   ├── sfx/
    │   └── music/
    └── fonts/
```

**Module Responsibilities:**

| Module | Responsibility | Inputs | Outputs |
|--------|---------------|--------|---------|
| **RockBreaker** | Detects clicks, reduces HP, triggers break | Mouse/Touch input | Break event → MineralSpawner |
| **MineralSpawner** | Rolls loot table, spawns Mineral instances | Break event, rock type | Mineral nodes (with physics) |
| **SortingSystem** | Validates drag-drop, awards points | Mineral + Bin ID | Points, bin progress, audio cue |
| **ProgressionManager** | Tracks unlocks, checks triggers | Player stats (rocks broken, minerals sorted) | Unlock signals, saves state |
| **DataLoader** | Reads JSON configs at runtime | File paths (data/*.json) | Dictionaries (rock types, minerals) |

**Communication:** Godot Signals (event-driven, decoupled).

Example:
```gdscript
# RockBreaker.gd
signal rock_broken(rock_type: String, position: Vector2)

func _on_rock_hp_zero():
    emit_signal("rock_broken", rock_type, global_position)

# MineralSpawner.gd (connected via editor or code)
func _on_rock_broken(rock_type: String, pos: Vector2):
    var loot = roll_loot_table(rock_type)
    spawn_minerals(loot, pos)
```

### 6.3 Data-Driven Design

**Config File Structure:**

**minerals.json:**
```json
{
  "version": "1.0",
  "minerals": [
    {
      "id": "ruby_small",
      "name": "Ruby Shard",
      "shape": "triangle",
      "color": "red",
      "rarity": "common",
      "points": 10,
      "sprite": "res://assets/sprites/minerals/ruby_small.png"
    }
  ]
}
```

**rocks.json:**
```json
{
  "rocks": [
    {
      "id": "stone_rock",
      "name": "Stone Rock",
      "hp": 1,
      "sprite": "res://assets/sprites/rocks/stone.png",
      "loot_table": {
        "common": ["ruby_small", "sapphire_small"],
        "uncommon": ["emerald_small"],
        "rare": []
      },
      "weights": { "common": 0.7, "uncommon": 0.25, "rare": 0.05 }
    }
  ]
}
```

**Benefits:**
1. **No Code Changes for Content:** Add new mineral → edit JSON, restart.
2. **Easy Balancing:** Tweak weights, point values without recompiling.
3. **Localization Ready:** JSON can hold translated strings (future).
4. **Designer-Friendly:** Non-programmers can edit configs.

**Loading at Runtime:**
```gdscript
# DataLoader.gd
var minerals: Dictionary = {}

func _ready():
    var file = FileAccess.open("res://data/minerals.json", FileAccess.READ)
    var json = JSON.parse_string(file.get_as_text())
    for mineral in json.minerals:
        minerals[mineral.id] = mineral
```

### 6.4 Performance Budget and Optimization

**Target Performance:**

| Platform | FPS | Resolution | Max Particles |
|----------|-----|------------|---------------|
| **PC (Mid-range)** | 60 FPS | 1920x1080 | 100 on-screen |
| **Mobile (Mid-tier)** | 60 FPS | 1080x1920 | 50 on-screen |
| **Web (Chrome)** | 60 FPS | 1280x720 | 75 on-screen |

**Optimization Strategies:**

1. **Object Pooling:**
   - Pre-instantiate 100 Mineral nodes at startup.
   - Reuse inactive nodes instead of `queue_free()` / `instance()`.
   - Godot: Use `Node.set_process(false)` to "deactivate."

2. **Physics Optimization:**
   - Use `RigidBody2D` for minerals, but disable after 3 seconds of rest (check `linear_velocity` threshold).
   - Spatial hashing via Godot's built-in physics (no custom needed).
   - No continuous collision detection (CCD) unless jitter observed.

3. **Draw Calls:**
   - Batch mineral sprites into a single `TextureAtlas` (reduces draw calls from 50 → 1).
   - Use `CanvasItem.draw_*` for bins (custom drawing) instead of separate Sprite nodes.

4. **Audio:**
   - Limit concurrent SFX to 8 (Godot's `AudioServer.set_bus_volume_db()` can duck).
   - Use `.ogg` for music (smaller than `.wav`), `.wav` for short SFX.

5. **Profiling Tools:**
   - Godot Profiler (Monitor tab): Track FPS, draw calls, physics time.
   - Target: <10ms per frame (60 FPS = 16.67ms budget).

**Degradation Strategy (Mobile):**
- If FPS drops below 55, reduce max particles by 20%.
- Disable background parallax on low-end devices (setting toggle).

---

## 7. MVP Scope (6–8 Weeks)

### 7.1 Feature List (Priority Order)

| # | Feature | Description | Acceptance Criteria |
|---|---------|-------------|---------------------|
| **1** | **Rock Breaking** | Click rock → HP decreases → breaks | **Given** a rock with 1 HP is on screen<br>**When** player clicks it<br>**Then** rock shatters, plays SFX, spawns 5-10 minerals |
| **2** | **Mineral Spawning** | Break rock → particles scatter | **Given** rock breaks<br>**When** loot table is rolled<br>**Then** minerals spawn at break position with random velocities, settle within 3s |
| **3** | **Auto-Collection** | Minerals near cursor auto-collect | **Given** minerals are resting<br>**When** cursor is within 100px<br>**Then** minerals fly to inventory with "ping" SFX |
| **4** | **Sorting Bins (2 types)** | Drag mineral to "Red" or "Blue" bin | **Given** player drags ruby to Red bin<br>**When** drop released<br>**Then** mineral locks in, plays "clink," bin progress updates (e.g., 5/10) |
| **5** | **Bin Completion Reward** | Full bin → bonus points + chime | **Given** bin reaches capacity (10/10)<br>**When** last mineral sorted<br>**Then** sparkle effect, +50 bonus, harmonious chime plays |
| **6** | **Score System** | Points for breaking, collecting, sorting | **Given** player breaks 1 rock, collects 5 rubies, sorts 3 correctly<br>**When** actions complete<br>**Then** score increases by 5 + 50 + 30 = 85 points |
| **7** | **Progression Tier 1** | Unlock at 20 rocks broken | **Given** player breaks 20th rock<br>**When** trigger checked<br>**Then** unlock notification appears, Granite Rock type available, +3 new minerals |
| **8** | **Save/Load System** | Auto-save after each bin completion | **Given** player completes a bin<br>**When** bin full event fires<br>**Then** game state (score, unlocks, inventory) saved to LocalStorage<br>**And** reloading game restores state |
| **9** | **UI: HUD (Score, Settings)** | Minimal top bar with score + gear icon | **Given** game running<br>**When** HUD visible<br>**Then** score updates in real-time, settings button opens pause menu |
| **10** | **UI: Inventory Panel** | Shows collected minerals (icon + count) | **Given** player has 5 rubies, 3 sapphires<br>**When** inventory panel rendered<br>**Then** shows [💎5] [🔷3] |
| **11** | **Audio: Core SFX (5 sounds)** | Break, collect, sort, complete, error | **Given** any of 5 core actions occur<br>**When** SFX triggered<br>**Then** corresponding sound plays at 70% volume, no overlap glitches |
| **12** | **Music: 1 Ambient Track** | Loops gently during gameplay | **Given** game starts<br>**When** music track "Gentle Quarry" plays<br>**Then** loops seamlessly, volume at 30%, no clicks/pops |
| **13** | **PC Controls** | Mouse click + drag | **Given** player uses mouse<br>**When** clicking rock and dragging mineral<br>**Then** actions work with <50ms latency, no missed inputs |
| **14** | **Settings Menu** | Volume sliders, colorblind toggle | **Given** player opens settings (Escape key)<br>**When** adjusting sliders<br>**Then** audio volumes change immediately; colorblind mode adds gem patterns |
| **15** | **Tutorial (3 Tooltips)** | First-time hints for tap, collect, sort | **Given** first launch<br>**When** game starts<br>**Then** 3 tooltips appear sequentially, dismissable with click, never show again |

### 7.2 Out of Scope (Post-MVP)

- Mobile touch controls (Week 9+)
- Zen Mode (Week 10+)
- Forest/Cave biomes (Week 12+)
- Custom bin criteria editor (Week 11+)
- Social features, leaderboards (not planned)
- Monetization (not planned)

### 7.3 Development Milestones

| Week | Milestone | Deliverable |
|------|-----------|-------------|
| **1-2** | Core Loop Prototype | Rock breaking + mineral spawn working (no art, gray boxes) |
| **3** | Sorting System | Drag-drop bins functional, basic validation |
| **4** | Art Pass 1 | Replace placeholders with pixel art sprites (rocks, 6 mineral types) |
| **5** | Audio Integration | All 5 core SFX + 1 music track implemented |
| **6** | Progression + Save | Unlock Tier 1 working, save/load tested |
| **7** | UI Polish | HUD, inventory, settings menu finalized |
| **8** | Testing + Bug Fixes | Playtest internally, fix crashes, balance tweaks |

---

## 8. Risks and Mitigations

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| **1** | **Physics Performance on Web** | Medium | High | Implement object pooling (Week 2). Limit particles to 75 on web builds. Profile early (Week 3). |
| **2** | **Drag-Drop Feels Clunky** | Medium | Medium | Prototype sorting in Week 3. Playtest with 3+ users. Add snap-to-bin magnetism if needed. |
| **3** | **Scoring Feels Stressful** | Low | High | Design scores as "bonus" not "goal." Playtest emphasis (Week 6). Add "Hide Score" toggle if feedback negative. |
| **4** | **Art Asset Delays** | Medium | Medium | Use free pixel art placeholders (itch.io, OpenGameArt). Commission 1-2 key sprites only if time allows. Prioritize rock + 6 gems. |
| **5** | **Scope Creep (Mobile Controls)** | High | Medium | Lock MVP to PC-only. Document mobile design in separate spec (Week 8). No mobile work until MVP validated. |

---

## 9. Success Metrics for Relaxation

**Philosophy:** "Relax" is subjective, but measurable through proxy metrics and qualitative feedback.

### 9.1 Quantitative Metrics

| Metric | Target (MVP) | Measurement Method |
|--------|--------------|-------------------|
| **Average Session Length** | 5–8 minutes | Track time from game start to quit (analytics) |
| **Session Completion Rate** | >70% | % of sessions where player completes ≥1 bin before quitting |
| **Return Rate (D1)** | >40% | % of players who return within 24 hours (LocalStorage timestamp) |
| **Error Rate (Mis-sorts)** | <10% of sorts | Track incorrect sorts / total sorts (data) |
| **Settings: "Hide Score" Usage** | 10-20% | Track how many players toggle this (opt-in stress reduction) |

### 9.2 Qualitative Metrics (Post-MVP Surveys)

**Post-Session Survey (Optional Pop-Up):**
1. "How relaxed do you feel?" (1-5 scale: Very Stressed → Very Relaxed)
2. "Did you feel a sense of accomplishment?" (Yes / No)
3. "What was most satisfying?" (Open text)

**Target:**
- Avg. relaxation score: ≥4.0/5.0
- "Sense of accomplishment" Yes: ≥80%

### 9.3 Behavioral Signals of Relax

| Behavior | Interpretation |
|----------|----------------|
| **Long idle times between actions** | Player is savoring, not rushing (good) |
| **Repeated "bin completion" actions** | Player enjoys closure moment (keep it rewarding) |
| **Low rage-quit rate** (<5% quit within 60s) | Game not frustrating |
| **Playtime at night (20:00-23:00)** | Used as wind-down tool (desired use case) |

### 9.4 Iteration Plan

- **Week 8:** Internal playtest with 5 users (team + friends). Collect qualitative feedback.
- **Week 10 (Post-MVP):** Public alpha with 50 players. Add in-game survey.
- **Adjust:** If relaxation scores <3.5, reduce visual noise, slow down particle speed, add Zen Mode earlier.

---

## Summary JSON

```json
{
  "summary": {
    "engine": "Godot 4.3+ (2D, cross-platform, open-source, data-driven friendly)",
    "core_loop": "Break rocks → Collect scattered minerals → Sort into bins → Earn points and unlocks → Repeat",
    "systems": [
      "Destruction and Physics (click rock, particles scatter with 2D physics, settle within 3s)",
      "Mineral Generation (6 colors, 5 shapes, 4 rarities, data-driven loot tables from JSON)",
      "Collection (auto-collect zone + manual tap, smooth animations, audio feedback)",
      "Sorting (drag-drop to bins, criteria validation, bin completion rewards with chime)",
      "Scoring (non-punishing, points for all actions, optional combo bonuses, no penalties)",
      "Progression (5 tiers unlock new rocks, tools, biomes; comfort-first pacing, auto-save)"
    ],
    "mvp_features": [
      "Rock breaking (1 HP stone rock, click to shatter, 5-10 minerals spawn)",
      "Mineral spawning (physics scatter, 6 types: ruby, sapphire, emerald, topaz, amethyst, diamond)",
      "Auto-collection (100px radius, smooth lerp animation, 'ping' SFX)",
      "Sorting bins (2 types: Red and Blue, drag-drop validation, 'clink' SFX on correct sort)",
      "Bin completion (10/10 triggers sparkle, +50 bonus, 3-note chime)",
      "Score system (points for break +5, collect +10-100, sort +10, bin bonus +50)",
      "Progression Tier 1 (unlock Granite Rock at 20 breaks, +3 minerals, +1 bin)",
      "Save/load (auto-save on bin complete, LocalStorage, restore on launch)",
      "UI HUD (score counter top-right, settings button, minimal design)",
      "Inventory panel (shows collected mineral counts with icons)",
      "Audio SFX (5 core sounds: break, collect, sort, complete, error at 70% volume)",
      "Music (1 ambient track 'Gentle Quarry', 60 BPM, loops at 30% volume)",
      "PC controls (mouse click/drag, keyboard shortcuts: 1-6 bin select, Space pause, Esc settings)",
      "Settings menu (volume sliders for Master/SFX/Music, colorblind mode toggle with patterns)",
      "Tutorial (3 dismissable tooltips on first launch: tap rock, collect, sort)"
    ],
    "risks": [
      "Physics performance on web builds (mitigate: object pooling, particle limit 75, profile Week 3)",
      "Drag-drop sorting feels clunky (mitigate: prototype Week 3, playtest, add snap-to-bin magnetism)",
      "Scoring system feels stressful (mitigate: design as bonus not goal, 'Hide Score' toggle if needed)",
      "Art asset delays (mitigate: use free placeholders from itch.io/OpenGameArt, prioritize 6 gem sprites + rocks)",
      "Scope creep with mobile controls (mitigate: lock MVP to PC-only, mobile in separate spec post-Week 8)"
    ],
    "metrics": [
      "Average session length: target 5-8 minutes (track time start to quit)",
      "Session completion rate: >70% complete ≥1 bin before quit",
      "Return rate D1: >40% players return within 24 hours",
      "Error rate: <10% incorrect sorts",
      "Hide Score toggle usage: 10-20% (proxy for stress reduction need)",
      "Post-session survey: relaxation score ≥4.0/5.0, accomplishment Yes ≥80%",
      "Behavioral: long idle times (savoring), repeated bin completions, <5% rage-quit rate"
    ]
  }
}
```

---

## Critical Questions (Answered Assumptions)

1. **2D Pixel Art confirmed** → All art direction, performance budgets, and engine choice optimized for 2D.
2. **Music + SFX in MVP confirmed** → 1 ambient track + 5 core SFX included in Week 5.
3. **Acceptance Criteria style** → User stories with Given/When/Then (concise, testable, designer-friendly).

**No further critical questions.** Design is self-consistent and MVP-scoped for 6-8 weeks.

---

**End of Game Design Document.**
