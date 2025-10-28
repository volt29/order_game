extends RigidBody2D
## Mineral entity - physics-enabled, collectable
## AC 2.1: Physics-Based Scatter
## AC 2.3: Visual Spawn Feedback

var mineral_id: String = ""
var mineral_data: Dictionary = {}
var is_resting: bool = false

signal mineral_resting()

func init(id: String, spawn_pos: Vector2) -> void:
	mineral_id = id
	position = spawn_pos

	# Load mineral data from DataLoader
	if DataLoader.minerals.has(mineral_id):
		mineral_data = DataLoader.minerals[mineral_id]

		# Try to load sprite texture
		var sprite_path = "res://sprites/minerals/%s.png" % mineral_id
		if FileAccess.file_exists(sprite_path):
			var texture = load(sprite_path)
			if texture:
				$Sprite2D.texture = texture
				$Sprite2D.visible = true
				$ColorRect.visible = false
		else:
			# Fallback to ColorRect
			if mineral_data.has("color_hex"):
				$ColorRect.color = Color(mineral_data.color_hex)
	else:
		push_warning("[Mineral] Mineral not found: " + mineral_id)

	# Apply random impulse (AC 2.1: scatter with physics)
	var angle = randf_range(-PI/4, PI/4)  # ±45°
	var force = randf_range(200, 400)
	var impulse = Vector2(cos(angle), -1).normalized() * force
	apply_impulse(impulse)

	# AC 2.3: Spawn feedback (simple fade-in)
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.15)

func _physics_process(_delta: float) -> void:
	# Detect resting state (AC 2.1: settle within 3 seconds)
	if not is_resting and linear_velocity.length() < 10:
		is_resting = true
		set_physics_process(false)  # Optimize: stop physics updates
		emit_signal("mineral_resting")
		print("[Mineral] %s is resting at %v" % [mineral_id, global_position])
