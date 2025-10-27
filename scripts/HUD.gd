extends Control
## HUD - displays score and combo
## AC 9.3: Real-Time Score Update

@onready var score_label = $ScoreLabel
@onready var combo_label = $ComboLabel

func _ready() -> void:
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.combo_triggered.connect(_on_combo_triggered)
	_update_combo_display()

func _on_score_changed(new_score: int) -> void:
	# AC 9.3: Update within 50ms (immediate in Godot signals)
	score_label.text = "Score: %d" % new_score

	# Simple scale animation (AC 9.3: scales 1.0 → 1.2 → 1.0)
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)

func _on_combo_triggered(bonus: int) -> void:
	# Flash combo label
	combo_label.text = "COMBO! +%d" % bonus
	var tween = create_tween()
	tween.tween_property(combo_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): combo_label.modulate.a = 1.0)
	tween.tween_callback(_update_combo_display)

func _update_combo_display() -> void:
	combo_label.text = "Combo: %d" % ScoreManager.combo_count

func _process(_delta: float) -> void:
	# Update combo count in real-time
	if ScoreManager.combo_count != int(combo_label.text.split(": ")[1] if ": " in combo_label.text else 0):
		_update_combo_display()
