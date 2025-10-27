extends Node2D
## Main scene orchestrator
## Spawns rocks, connects signals, manages game flow

@onready var playfield = $Playfield
@onready var minerals_container = $MineralsContainer

var rock_scene = preload("res://scenes/Rock.tscn")

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
	# TODO: Spawn minerals (Phase 4)

	# Respawn a new rock after 1 second (for testing)
	await get_tree().create_timer(1.0).timeout
	var new_rock_type = "stone_rock" if randf() > 0.3 else "granite_rock"
	spawn_rock(new_rock_type, Vector2(randf_range(-200, 200), randf_range(-200, 200)))
