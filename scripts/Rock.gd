extends StaticBody2D
## Rock entity - clickable, has HP, emits signal on break
## AC 1.1: Single-HP Rock Breaking
## AC 1.2: Multi-HP Rock Breaking with visual crack

@export var rock_type: String = "stone_rock"
@export var max_hp: int = 1
var current_hp: int:
	set(value):
		current_hp = value
		_update_visual()

signal rock_hit(position: Vector2)
signal rock_broken(rock_type: String, position: Vector2)

func _ready() -> void:
	# Load rock data from DataLoader
	if DataLoader.rocks.has(rock_type):
		var rock_data = DataLoader.rocks[rock_type]
		max_hp = rock_data.hp
		current_hp = max_hp
		# Set color from rock data
		if rock_data.has("color_hex"):
			$ColorRect.color = Color(rock_data.color_hex)
	else:
		push_warning("[Rock] Rock type not found: " + rock_type)
		current_hp = max_hp

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# AC 1.1, 1.2: Detect click, reduce HP
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		take_damage(1)

func take_damage(amount: int) -> void:
	current_hp -= amount
	emit_signal("rock_hit", global_position)

	# Flash white (hit feedback)
	_flash_white()

	if current_hp <= 0:
		_break_rock()

func _break_rock() -> void:
	emit_signal("rock_broken", rock_type, global_position)
	# TODO: Play SFX "rock_break.wav"
	# TODO: Spawn shatter particles
	queue_free()

func _update_visual() -> void:
	# Show cracks based on HP (simple version: darken color)
	if current_hp < max_hp:
		var hp_ratio = float(current_hp) / float(max_hp)
		$ColorRect.modulate = Color(hp_ratio, hp_ratio, hp_ratio, 1.0)

func _flash_white() -> void:
	# Simple flash effect: modulate to white for 0.1s
	var original_modulate = $ColorRect.modulate
	$ColorRect.modulate = Color(1.5, 1.5, 1.5, 1.0)
	await get_tree().create_timer(0.1).timeout
	$ColorRect.modulate = original_modulate
