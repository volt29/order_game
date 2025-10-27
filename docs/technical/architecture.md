# Technical Architecture

**Project:** Order Game
**Version:** 1.0
**Date:** 2025-10-27
**Engine:** Godot 4.3+

This document describes the technical architecture, module structure, data flow, and implementation patterns for the Order Game MVP.

---

## 1. Architecture Overview

**Pattern:** Modular Event-Driven Architecture
**Communication:** Godot Signals (observer pattern)
**Data Flow:** Data-Driven (JSON configs loaded at runtime)

### 1.1 High-Level Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        MAIN SCENE                            │
│  (Manages game state, coordinates modules)                   │
└─────────┬───────────────────────────────────────────────────┘
          │
          ├──→ [DataLoader] ←─── loads ───→ [JSON Configs]
          │         │                        (minerals.json,
          │         │                         rocks.json, etc.)
          │         ↓ (provides dictionaries)
          │
          ├──→ [Playfield] ──→ spawns ──→ [Rocks]
          │         │                         │
          │         │                         └─→ clicks ──→ [RockBreaker]
          │         │                                            │
          │         ↓ (rock_broken signal)                       ↓
          │                                                 (reduces HP)
          │    [MineralSpawner] ←─────────────────────────────┘
          │         │
          │         ↓ (spawns Mineral instances w/ physics)
          │
          ├──→ [CollectionZone] ──→ detects ──→ [Minerals]
          │         │                              │
          │         ↓ (mineral_collected signal)   │
          │                                         ↓
          │    [InventoryManager] ←─────────── (stores counts)
          │         │
          │         ↓ (provides mineral data)
          │
          ├──→ [SortingSystem] ──→ validates ──→ [SortingBins]
          │         │                               │
          │         ↓ (bin_complete signal)         │
          │                                          ↓
          │    [ScoreManager] ←─────────────── (awards points)
          │         │
          │         ↓ (score_changed signal)
          │
          ├──→ [ProgressionManager] ──→ checks ──→ [Unlock Triggers]
          │         │                                │
          │         ↓ (unlock_achieved signal)       │
          │                                           ↓
          │    [SaveSystem] ←───────────────── (persists state)
          │
          └──→ [UI Layer]
                 ├─ HUD (score, settings button)
                 ├─ InventoryPanel (mineral icons)
                 ├─ BinUI (sorting bins, progress bars)
                 └─ SettingsMenu (pause, volumes, colorblind)
```

---

## 2. Core Modules

### 2.1 DataLoader

**Responsibility:** Load and parse JSON config files at runtime.

**Script:** `scripts/DataLoader.gd`
**Type:** Singleton (AutoLoad)

**Public Methods:**
```gdscript
func load_minerals() -> Dictionary:
    # Returns: { "ruby_small": { name: "Ruby", color: "red", ... }, ... }

func load_rocks() -> Dictionary:
    # Returns: { "stone_rock": { hp: 1, loot_table: {...}, ... }, ... }

func load_progression() -> Array:
    # Returns: [ { tier: 1, trigger: "rocks_broken >= 20", unlocks: [...] }, ... ]
```

**Data Sources:**
- `data/minerals.json`
- `data/rocks.json`
- `data/progression.json`

**Error Handling:**
- If file missing → log error, return empty dict, use fallback defaults
- If JSON invalid → parse error message, graceful degradation

**Example Usage:**
```gdscript
# In _ready():
var minerals = DataLoader.load_minerals()
print(minerals["ruby_small"].name)  # "Ruby Shard"
```

---

### 2.2 RockBreaker

**Responsibility:** Detect clicks on rocks, reduce HP, trigger break event.

**Scene:** `scenes/RockBreaker.tscn`
**Script:** `scripts/Rock.gd` (attached to each Rock instance)

**Properties:**
```gdscript
@export var rock_type: String = "stone_rock"  # ID from rocks.json
@export var max_hp: int = 1
var current_hp: int = max_hp
```

**Signals:**
```gdscript
signal rock_hit(position: Vector2)
signal rock_broken(rock_type: String, position: Vector2)
```

**Methods:**
```gdscript
func _on_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.pressed:
        take_damage(1)

func take_damage(amount: int):
    current_hp -= amount
    emit_signal("rock_hit", global_position)
    if current_hp <= 0:
        emit_signal("rock_broken", rock_type, global_position)
        queue_free()
    else:
        show_crack_sprite()
```

**Visual Feedback:**
- Flash white (modulate tween)
- Show crack sprite (`crack_1.png`, etc.)
- Screen shake (Camera2D.offset tween)

**SFX:**
- On hit: `sfx_rock_hit.wav`
- On break: `sfx_rock_break.wav`

---

### 2.3 MineralSpawner

**Responsibility:** Roll loot table, spawn Mineral instances with physics.

**Scene:** `scenes/MineralSpawner.tscn`
**Script:** `scripts/MineralSpawner.gd`

**Connected Signals:**
```gdscript
# In Playfield._ready():
for rock in rocks:
    rock.connect("rock_broken", _on_rock_broken)

func _on_rock_broken(rock_type: String, position: Vector2):
    MineralSpawner.spawn_minerals(rock_type, position)
```

**Methods:**
```gdscript
func spawn_minerals(rock_type: String, position: Vector2):
    var loot_table = DataLoader.rocks[rock_type].loot_table
    var minerals_to_spawn = roll_loot(loot_table)  # Returns array of mineral IDs
    for mineral_id in minerals_to_spawn:
        var mineral = preload("res://scenes/Mineral.tscn").instantiate()
        mineral.init(mineral_id, position)
        add_child(mineral)

func roll_loot(loot_table: Dictionary) -> Array:
    var result = []
    var count = randi_range(5, 10)  # 5-10 minerals
    for i in count:
        var rarity = roll_rarity(loot_table.weights)  # "common", "uncommon", "rare"
        var mineral_id = loot_table[rarity].pick_random()
        result.append(mineral_id)
    return result

func roll_rarity(weights: Dictionary) -> String:
    var roll = randf()
    if roll < weights.common:
        return "common"
    elif roll < weights.common + weights.uncommon:
        return "uncommon"
    else:
        return "rare"
```

**Physics:**
- Each Mineral is a `RigidBody2D`
- Apply random impulse on spawn (angle: ±45°, force: 200-400)
- Gravity: 980 (default)
- Linear Damp: 2.0 (slows down)
- Settle after 3s (check `linear_velocity.length() < 10`)

---

### 2.4 Mineral (Entity)

**Scene:** `scenes/Mineral.tscn`
**Script:** `scripts/Mineral.gd`

**Node Structure:**
```
Mineral (RigidBody2D)
├─ Sprite2D (mineral texture)
├─ CollisionShape2D (circle, radius 8px)
└─ CPUParticles2D (sparkle on spawn)
```

**Properties:**
```gdscript
var mineral_id: String  # e.g., "ruby_small"
var mineral_data: Dictionary  # From DataLoader
var is_resting: bool = false  # True when velocity near zero

func init(id: String, spawn_pos: Vector2):
    mineral_id = id
    mineral_data = DataLoader.minerals[id]
    position = spawn_pos
    apply_impulse(Vector2(randf_range(-200, 200), -400))
    sprite.texture = load(mineral_data.sprite)
```

**Resting Detection:**
```gdscript
func _physics_process(delta):
    if linear_velocity.length() < 10 and not is_resting:
        is_resting = true
        set_physics_process(false)  # Optimize: disable physics
```

---

### 2.5 CollectionZone

**Responsibility:** Auto-collect minerals near cursor.

**Scene:** `scenes/CollectionZone.tscn`
**Script:** `scripts/CollectionZone.gd`

**Node Structure:**
```
CollectionZone (Area2D)
├─ CollisionShape2D (circle, radius 100px)
```

**Methods:**
```gdscript
func _process(delta):
    global_position = get_global_mouse_position()  # Follow cursor

func _on_area_entered(area):
    if area is Mineral and area.is_resting:
        collect_mineral(area)

func collect_mineral(mineral: Mineral):
    # Tween toward cursor
    var tween = create_tween()
    tween.tween_property(mineral, "global_position", global_position, 0.3)
    tween.tween_callback(mineral.queue_free)

    # Update inventory
    InventoryManager.add_mineral(mineral.mineral_id, 1)

    # SFX
    AudioManager.play_sfx("sfx_mineral_collect")
```

**Signals:**
```gdscript
signal mineral_collected(mineral_id: String)
```

---

### 2.6 InventoryManager

**Responsibility:** Track collected mineral counts.

**Script:** `scripts/InventoryManager.gd`
**Type:** Singleton (AutoLoad)

**State:**
```gdscript
var inventory: Dictionary = {}  # { "ruby_small": 5, "sapphire_small": 3, ... }

signal inventory_changed(mineral_id: String, count: int)
```

**Methods:**
```gdscript
func add_mineral(mineral_id: String, amount: int = 1):
    if not inventory.has(mineral_id):
        inventory[mineral_id] = 0
    inventory[mineral_id] += amount
    emit_signal("inventory_changed", mineral_id, inventory[mineral_id])

func remove_mineral(mineral_id: String, amount: int = 1) -> bool:
    if inventory.get(mineral_id, 0) >= amount:
        inventory[mineral_id] -= amount
        emit_signal("inventory_changed", mineral_id, inventory[mineral_id])
        return true
    return false

func get_count(mineral_id: String) -> int:
    return inventory.get(mineral_id, 0)
```

---

### 2.7 SortingSystem

**Responsibility:** Validate drag-drop, award points, manage bins.

**Scene:** `scenes/SortingSystem.tscn`
**Script:** `scripts/SortingSystem.gd`

**Child Nodes:**
```
SortingSystem (Node2D)
├─ Bin1 (SortingBin)
├─ Bin2 (SortingBin)
└─ Bin3 (SortingBin)
```

**SortingBin Script:** `scripts/SortingBin.gd`

**Bin Properties:**
```gdscript
@export var criteria_type: String = "color"  # "color", "shape", "rarity"
@export var criteria_value: String = "red"   # e.g., "red", "triangle"
@export var capacity: int = 10

var current_count: int = 0

signal mineral_sorted(mineral_id: String, success: bool)
signal bin_complete()
```

**Methods:**
```gdscript
func try_sort(mineral_id: String) -> bool:
    var mineral_data = DataLoader.minerals[mineral_id]
    var matches = false

    if criteria_type == "color":
        matches = mineral_data.color == criteria_value
    elif criteria_type == "shape":
        matches = mineral_data.shape == criteria_value

    if matches and current_count < capacity:
        current_count += 1
        emit_signal("mineral_sorted", mineral_id, true)
        AudioManager.play_sfx("sfx_sort_correct")
        ScoreManager.add_points(10)

        if current_count == capacity:
            emit_signal("bin_complete")
            trigger_completion()
        return true
    else:
        emit_signal("mineral_sorted", mineral_id, false)
        AudioManager.play_sfx("sfx_sort_error")
        return false

func trigger_completion():
    # VFX
    var particles = preload("res://scenes/SparkleEffect.tscn").instantiate()
    add_child(particles)

    # SFX
    AudioManager.play_sfx("sfx_bin_complete")

    # Bonus
    ScoreManager.add_points(50)

    # Reset
    await get_tree().create_timer(2.0).timeout
    current_count = 0
```

---

### 2.8 ScoreManager

**Responsibility:** Track score, calculate bonuses.

**Script:** `scripts/ScoreManager.gd`
**Type:** Singleton (AutoLoad)

**State:**
```gdscript
var score: int = 0
var combo_count: int = 0

signal score_changed(new_score: int)
signal combo_triggered(bonus: int)
```

**Methods:**
```gdscript
func add_points(amount: int):
    score += amount
    emit_signal("score_changed", score)

func increment_combo():
    combo_count += 1
    if combo_count == 5:
        add_points(25)
        emit_signal("combo_triggered", 25)
        combo_count = 0

func reset_combo():
    combo_count = 0
```

**Connected Events:**
```gdscript
# In SortingBin:
func try_sort(mineral_id: String) -> bool:
    if matches:
        ScoreManager.increment_combo()
    else:
        ScoreManager.reset_combo()
```

---

### 2.9 ProgressionManager

**Responsibility:** Track progress, check unlock triggers.

**Script:** `scripts/ProgressionManager.gd`
**Type:** Singleton (AutoLoad)

**State:**
```gdscript
var current_tier: int = 0
var rocks_broken: int = 0
var bins_completed: int = 0

signal unlock_achieved(tier: int, unlocks: Array)
```

**Methods:**
```gdscript
func register_rock_broken():
    rocks_broken += 1
    check_unlocks()

func register_bin_completed():
    bins_completed += 1
    check_unlocks()

func check_unlocks():
    var tiers = DataLoader.load_progression()
    for tier_data in tiers:
        if tier_data.tier > current_tier:
            if evaluate_trigger(tier_data.trigger):
                current_tier = tier_data.tier
                emit_signal("unlock_achieved", current_tier, tier_data.unlocks)
                SaveSystem.save_game()

func evaluate_trigger(trigger: String) -> bool:
    # Example: "rocks_broken >= 20"
    var expression = Expression.new()
    expression.parse(trigger)
    return expression.execute([self])
```

---

### 2.10 SaveSystem

**Responsibility:** Serialize/deserialize game state to LocalStorage.

**Script:** `scripts/SaveSystem.gd`
**Type:** Singleton (AutoLoad)

**Methods:**
```gdscript
const SAVE_KEY = "order_game_save"

func save_game():
    var save_data = {
        "version": "1.0",
        "score": ScoreManager.score,
        "tier": ProgressionManager.current_tier,
        "rocks_broken": ProgressionManager.rocks_broken,
        "bins_completed": ProgressionManager.bins_completed,
        "inventory": InventoryManager.inventory
    }
    var json = JSON.stringify(save_data)
    var file = FileAccess.open("user://save.json", FileAccess.WRITE)
    file.store_string(json)
    file.close()

func load_game():
    if not FileAccess.file_exists("user://save.json"):
        return  # New game

    var file = FileAccess.open("user://save.json", FileAccess.READ)
    var json = file.get_as_text()
    file.close()

    var save_data = JSON.parse_string(json)
    if save_data:
        ScoreManager.score = save_data.score
        ProgressionManager.current_tier = save_data.tier
        ProgressionManager.rocks_broken = save_data.rocks_broken
        InventoryManager.inventory = save_data.inventory
```

**Auto-Save Trigger:**
```gdscript
# In SortingBin.trigger_completion():
SaveSystem.save_game()
```

---

## 3. Data Flow Diagrams

### 3.1 Core Loop Flow

```
Player Clicks Rock
       │
       ▼
  [RockBreaker]
    ├─ HP -= 1
    ├─ Emit rock_hit signal → Play SFX
    └─ If HP == 0:
          ├─ Emit rock_broken(rock_type, position)
          └─ queue_free()
       │
       ▼
  [MineralSpawner] (listens to rock_broken)
    ├─ Roll loot_table → Get 5-10 mineral IDs
    ├─ Instantiate Mineral scenes
    └─ Apply physics impulse
       │
       ▼
  [Minerals] (scatter, settle after 3s)
       │
       ▼
  [CollectionZone] (detects resting minerals)
    ├─ Tween mineral to cursor
    ├─ Emit mineral_collected(mineral_id)
    └─ queue_free()
       │
       ▼
  [InventoryManager] (updates inventory[mineral_id] += 1)
    ├─ Emit inventory_changed
    └─ UI updates
       │
       ▼
  Player Drags Mineral to Bin
       │
       ▼
  [SortingBin]
    ├─ Validate criteria (color/shape/rarity)
    ├─ If match:
    │    ├─ current_count += 1
    │    ├─ ScoreManager.add_points(10)
    │    ├─ ScoreManager.increment_combo()
    │    └─ If current_count == capacity:
    │         ├─ Emit bin_complete
    │         ├─ Play sparkle VFX + chime SFX
    │         ├─ ScoreManager.add_points(50)
    │         ├─ SaveSystem.save_game()
    │         └─ Reset bin to 0/10
    └─ If mismatch:
         ├─ Bounce mineral back
         ├─ Play error SFX
         └─ ScoreManager.reset_combo()
       │
       ▼
  [ProgressionManager]
    ├─ Check triggers (rocks_broken >= 20)
    └─ If unlock achieved:
         ├─ Emit unlock_achieved(tier, unlocks)
         ├─ Show notification UI
         └─ Save state
```

### 3.2 Save/Load Flow

```
Game Launch
    │
    ▼
[SaveSystem.load_game()]
    ├─ Read "user://save.json"
    ├─ Parse JSON
    ├─ Restore ScoreManager.score
    ├─ Restore ProgressionManager.tier
    └─ Restore InventoryManager.inventory
    │
    ▼
[Main Scene _ready()]
    ├─ DataLoader.load_minerals()
    ├─ DataLoader.load_rocks()
    ├─ Spawn initial rocks
    └─ Initialize UI with restored state

─────────────────────────────────────────

Bin Completion Event
    │
    ▼
[SortingBin.trigger_completion()]
    ├─ Play VFX/SFX
    ├─ Award bonus points
    └─ Call SaveSystem.save_game()
    │
    ▼
[SaveSystem.save_game()]
    ├─ Serialize state to JSON
    ├─ Write to "user://save.json"
    └─ Log success
```

---

## 4. Scene Hierarchy

### 4.1 Main Scene Structure

```
Main (Node2D)
├─ Camera2D (follows playfield, screen shake)
├─ Background (Sprite2D or ParallaxBackground)
├─ Playfield (Node2D)
│   ├─ RockSpawner (spawns Rock instances)
│   ├─ MineralSpawner (spawns Mineral instances)
│   └─ CollectionZone (Area2D, follows mouse)
├─ SortingSystem (Node2D)
│   ├─ Bin1 (SortingBin)
│   ├─ Bin2 (SortingBin)
│   └─ Bin3 (SortingBin)
└─ UI (CanvasLayer)
    ├─ HUD (Control)
    │   ├─ ScoreLabel (Label)
    │   └─ SettingsButton (TextureButton)
    ├─ InventoryPanel (Control)
    │   └─ MineralIcons (HBoxContainer)
    ├─ BinUI (Control)
    │   └─ BinProgressBars (grid of UI elements)
    └─ SettingsMenu (Control, initially hidden)
        ├─ VolumeSliders (HSlider × 3)
        ├─ ColorblindToggle (CheckButton)
        └─ ResumeButton (Button)
```

### 4.2 Prefabs (Instantiable Scenes)

| Scene | Path | Usage |
|-------|------|-------|
| Rock.tscn | `scenes/Rock.tscn` | Instantiated by RockSpawner |
| Mineral.tscn | `scenes/Mineral.tscn` | Instantiated by MineralSpawner |
| SortingBin.tscn | `scenes/SortingBin.tscn` | Pre-placed in SortingSystem |
| SparkleEffect.tscn | `scenes/effects/SparkleEffect.tscn` | Instantiated on bin complete |

---

## 5. Object Pooling (Optimization)

**Problem:** Frequent `instantiate()` and `queue_free()` causes GC spikes.

**Solution:** Pre-instantiate 100 Mineral nodes, reuse inactive ones.

### 5.1 MineralPool Singleton

**Script:** `scripts/MineralPool.gd`

```gdscript
extends Node

const POOL_SIZE = 100
var pool: Array[Mineral] = []
var active_minerals: Array[Mineral] = []

func _ready():
    var mineral_scene = preload("res://scenes/Mineral.tscn")
    for i in POOL_SIZE:
        var mineral = mineral_scene.instantiate()
        mineral.set_process(false)
        mineral.visible = false
        add_child(mineral)
        pool.append(mineral)

func spawn_mineral(mineral_id: String, position: Vector2) -> Mineral:
    if pool.is_empty():
        push_warning("Mineral pool exhausted!")
        return null

    var mineral = pool.pop_back()
    mineral.init(mineral_id, position)
    mineral.visible = true
    mineral.set_process(true)
    active_minerals.append(mineral)
    return mineral

func return_mineral(mineral: Mineral):
    mineral.visible = false
    mineral.set_process(false)
    active_minerals.erase(mineral)
    pool.append(mineral)
```

**Usage in MineralSpawner:**
```gdscript
func spawn_minerals(rock_type: String, position: Vector2):
    var minerals_to_spawn = roll_loot(rock_type)
    for mineral_id in minerals_to_spawn:
        MineralPool.spawn_mineral(mineral_id, position)
```

**Return to Pool:**
```gdscript
# In CollectionZone.collect_mineral():
func collect_mineral(mineral: Mineral):
    var tween = create_tween()
    tween.tween_property(mineral, "global_position", global_position, 0.3)
    tween.tween_callback(func(): MineralPool.return_mineral(mineral))
```

---

## 6. Performance Profiling

### 6.1 Godot Profiler Targets

| Metric | Target | Warning Threshold | Critical |
|--------|--------|-------------------|----------|
| **FPS** | 60 | <58 | <50 |
| **Frame Time** | <16.67ms | >17ms | >20ms |
| **Physics Time** | <5ms | >7ms | >10ms |
| **Draw Calls** | <50 | >80 | >100 |
| **Active Nodes** | <500 | >800 | >1000 |

### 6.2 Profiling Steps

1. Open Godot Editor → **Debugger** tab → **Profiler**
2. Run game in debug mode
3. Break 10 rocks, observe metrics
4. Check:
   - **Physics Time:** Should stay <5ms (object pooling helps)
   - **Draw Calls:** Should stay <50 (TextureAtlas batching helps)
   - **Script Functions:** `Mineral._physics_process` should be <1% CPU (disable on rest)

### 6.3 Bottleneck Mitigation

| Bottleneck | Solution |
|------------|----------|
| Too many `_physics_process` calls | Disable physics on resting minerals |
| High draw calls (50+) | Use TextureAtlas for all mineral sprites |
| GC spikes | Use object pooling for Mineral instances |
| Audio clipping | Limit concurrent SFX to 8 via AudioServer |

---

## 7. Testing Strategy

### 7.1 Unit Tests (GDScript)

**Tool:** [GdUnit4](https://github.com/MikeSchulze/gdUnit4)

**Example Test:**
```gdscript
# tests/test_sorting_bin.gd
extends GdUnitTestSuite

func test_sort_correct_mineral():
    var bin = SortingBin.new()
    bin.criteria_type = "color"
    bin.criteria_value = "red"

    var result = bin.try_sort("ruby_small")  # Ruby is red
    assert_true(result)
    assert_int(bin.current_count).is_equal(1)

func test_sort_incorrect_mineral():
    var bin = SortingBin.new()
    bin.criteria_type = "color"
    bin.criteria_value = "red"

    var result = bin.try_sort("sapphire_small")  # Sapphire is blue
    assert_false(result)
    assert_int(bin.current_count).is_equal(0)
```

**Run Tests:**
```bash
godot --headless --script res://addons/gdUnit4/bin/TestRunner.gd
```

### 7.2 Integration Tests

**Manual Playtest Checklist:**
- [ ] Break 20 rocks → Tier 1 unlock notification appears
- [ ] Complete bin → save file created in `user://save.json`
- [ ] Close game, reopen → score and tier restored
- [ ] Adjust volume sliders → audio changes immediately
- [ ] Enable colorblind mode → gem patterns appear

### 7.3 Performance Tests

**Stress Test:**
1. Spawn 50 minerals on screen simultaneously
2. Measure FPS (target: ≥55 FPS)
3. Check physics time (target: <10ms)

**Web Export Test:**
1. Export to HTML5
2. Test in Chrome, Firefox
3. Verify 60 FPS with 75 minerals max

---

## 8. Extensibility Patterns

### 8.1 Adding New Mineral Types

**Steps:**
1. Add entry to `data/minerals.json`:
   ```json
   {
     "id": "obsidian_shard",
     "name": "Obsidian",
     "shape": "triangle",
     "color": "black",
     "rarity": "rare",
     "points": 50,
     "sprite": "res://assets/sprites/minerals/obsidian.png"
   }
   ```
2. Create sprite `assets/sprites/minerals/obsidian.png` (16x16px)
3. Add `obsidian_shard` to rock loot tables in `rocks.json`
4. **No code changes needed** (data-driven)

### 8.2 Adding New Biomes

**Steps:**
1. Create `data/biomes.json`:
   ```json
   {
     "biomes": [
       {
         "id": "forest",
         "background": "res://assets/backgrounds/forest.png",
         "music": "res://assets/audio/music/forest_whispers.ogg",
         "rock_spawn_weights": { "granite": 0.5, "marble": 0.3, "stone": 0.2 }
       }
     ]
   }
   ```
2. Add `BiomeManager.gd` singleton to load biomes
3. Trigger biome change on unlock (emit signal, swap background/music)

### 8.3 Adding Custom Bin Criteria

**Steps:**
1. Extend `SortingBin.try_sort()`:
   ```gdscript
   elif criteria_type == "rarity":
       matches = mineral_data.rarity == criteria_value
   ```
2. Add UI toggle in SettingsMenu: "Sort by Rarity"
3. Save preference in `SaveSystem`

---

## 9. Build Pipeline

### 9.1 Export Presets

**Platforms:**
1. **Windows Desktop** (exe, 64-bit)
2. **macOS** (app bundle, Universal)
3. **Linux** (x86_64)
4. **HTML5 (Web)** (wasm, threads disabled for compatibility)

**Godot Export Settings:**
- **Texture Format:** Detect (VRAM Compressed)
- **Export Mode:** Release (strip debug symbols)
- **Encryption:** None (MVP)

### 9.2 Build Commands

```bash
# Export Windows
godot --headless --export-release "Windows Desktop" builds/OrderGame_Windows.exe

# Export Web
godot --headless --export-release "HTML5" builds/web/index.html

# Run Web Server (test locally)
cd builds/web && python -m http.server 8000
```

### 9.3 CI/CD (Optional Post-MVP)

**Tool:** GitHub Actions

**Workflow:**
1. On push to `main` branch
2. Run GdUnit4 tests
3. Export Windows + Web builds
4. Upload to itch.io (Butler CLI)

---

## 10. Deployment Checklist

**Pre-Release:**
- [ ] All 15 MVP features pass acceptance tests
- [ ] Performance: 60 FPS on mid-range PC with 100 minerals
- [ ] Save/load works (test corrupted save file)
- [ ] Colorblind mode tested with simulators
- [ ] Audio: No clipping, all 5 SFX + 1 music track play
- [ ] Builds exported for Windows, macOS, Linux, Web
- [ ] README.md updated with "How to Play" section

**Post-Release:**
- [ ] Monitor crash reports (Godot crash handler logs)
- [ ] Collect metrics (avg session length, D1 retention)
- [ ] Plan Tier 2-4 content (Forest biome, Zen Mode)

---

**End of Technical Architecture.**
