extends Node2D
## Main scene orchestrator
## Spawns rocks, connects signals, manages game flow

@onready var playfield = $Playfield
@onready var minerals_container = $MineralsContainer

var rock_scene = preload("res://scenes/Rock.tscn")
var mineral_scene = preload("res://scenes/Mineral.tscn")

func _ready() -> void:
	print("[Main] Game started")
	spawn_rock("stone_rock", Vector2.ZERO)

func spawn_rock(rock_type: String, offset: Vector2) -> void:
	var rock = rock_scene.instantiate()
	rock.rock_type = rock_type
	rock.position = offset
	rock.rock_broken.connect(_on_rock_broken)
	playfield.add_child(rock)
	print("[Main] Spawned rock: %s at %v" % [rock_type, offset])

func _on_rock_broken(rock_type: String, position: Vector2) -> void:
	print("[Main] Rock broken: %s at %v" % [rock_type, position])
	spawn_minerals(rock_type, position)

	# Respawn a new rock after 1 second (for testing)
	await get_tree().create_timer(1.0).timeout
	var new_rock_type = "stone_rock" if randf() > 0.3 else "granite_rock"
	spawn_rock(new_rock_type, Vector2(randf_range(-200, 200), randf_range(-200, 200)))

func spawn_minerals(rock_type: String, spawn_position: Vector2) -> void:
	## AC 2.2: Loot Table Randomization
	if not DataLoader.rocks.has(rock_type):
		push_error("[Main] Rock type not found: " + rock_type)
		return

	var rock_data = DataLoader.rocks[rock_type]
	var loot_table = rock_data.loot_table
	var weights = rock_data.weights
	var min_drops = rock_data.get("min_drops", 5)
	var max_drops = rock_data.get("max_drops", 10)

	var num_minerals = randi_range(min_drops, max_drops)
	print("[Main] Spawning %d minerals from %s" % [num_minerals, rock_type])

	for i in range(num_minerals):
		var rarity = _roll_rarity(weights)
		var mineral_ids = loot_table.get(rarity, [])
		if mineral_ids.is_empty():
			push_warning("[Main] No minerals for rarity: " + rarity)
			continue

		var mineral_id = mineral_ids[randi() % mineral_ids.size()]
		_spawn_single_mineral(mineral_id, spawn_position)

func _spawn_single_mineral(mineral_id: String, spawn_position: Vector2) -> void:
	var mineral = mineral_scene.instantiate()
	minerals_container.add_child(mineral)
	mineral.init(mineral_id, spawn_position)

func _roll_rarity(weights: Dictionary) -> String:
	## Roll a weighted random rarity (common, uncommon, rare)
	var roll = randf()
	var cumulative = 0.0

	if weights.has("common"):
		cumulative += weights.common
		if roll < cumulative:
			return "common"

	if weights.has("uncommon"):
		cumulative += weights.uncommon
		if roll < cumulative:
			return "uncommon"

	return "rare"
