extends Control
## SortingBin - placeholder implementation
## AC 4.1: Drag-and-Drop Mechanics (simplified for prototype)
## Full drag-drop to be implemented later

@export var criteria_type: String = "color"  # "color", "shape", "rarity"
@export var criteria_value: String = "red"
@export var capacity: int = 10

var current_count: int = 0

signal mineral_sorted(mineral_id: String, success: bool)
signal bin_complete()

func _ready() -> void:
	$Button.pressed.connect(_on_button_pressed)
	_update_label()

	# Enable drag-drop detection
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_button_pressed() -> void:
	# Placeholder: "Sort" the first matching mineral from inventory
	# AC 4.1: In full version, this would be drag-drop
	var sorted = _try_sort_from_inventory()
	if sorted:
		print("[SortingBin] Sorted %s to %s bin" % [sorted, criteria_value])

## AC 4.1: Drag-and-Drop Mechanics - Full Implementation
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Validate if the dropped mineral matches this bin's criteria
	if data is String:  # mineral_id from InventoryPanel
		var mineral_id = data as String
		var mineral_data = DataLoader.get_mineral(mineral_id)

		# Check if mineral matches criteria and bin has space
		if _matches_criteria(mineral_data) and current_count < capacity:
			# Check if player has this mineral in inventory
			return InventoryManager.get_count(mineral_id) > 0
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# Handle the actual sorting when mineral is dropped
	var mineral_id = data as String

	# Remove from inventory
	if InventoryManager.remove_mineral(mineral_id, 1):
		current_count += 1
		_update_label()
		emit_signal("mineral_sorted", mineral_id, true)

		# AC 6.1: Award points for correct sort
		ScoreManager.add_points(10)
		ScoreManager.increment_combo()

		# Track stats
		SaveSystem.increment_stat("total_minerals_sorted")

		# Audio + Visual feedback
		AudioManager.play_sfx("sort_correct")
		_flash_success()

		print("[SortingBin] Sorted %s to %s bin (drag-drop)" % [mineral_id, criteria_value])

		# Check for completion
		if current_count >= capacity:
			_trigger_completion()
	else:
		print("[SortingBin] ERROR: Failed to remove mineral from inventory")

func _try_sort_from_inventory() -> String:
	# Find first mineral in inventory matching criteria
	for mineral_id in InventoryManager.inventory.keys():
		var count = InventoryManager.get_count(mineral_id)
		if count > 0:
			var mineral_data = DataLoader.get_mineral(mineral_id)
			if _matches_criteria(mineral_data):
				# Remove from inventory
				if InventoryManager.remove_mineral(mineral_id, 1):
					current_count += 1
					_update_label()
					emit_signal("mineral_sorted", mineral_id, true)
					ScoreManager.add_points(10)
					ScoreManager.increment_combo()
					SaveSystem.increment_stat("total_minerals_sorted")
					AudioManager.play_sfx("sort_correct")

					if current_count >= capacity:
						_trigger_completion()
					return mineral_id
	print("[SortingBin] No matching minerals in inventory")
	return ""

func _matches_criteria(mineral_data: Dictionary) -> bool:
	if criteria_type == "color":
		return mineral_data.get("color", "") == criteria_value
	elif criteria_type == "shape":
		return mineral_data.get("shape", "") == criteria_value
	return false

func _trigger_completion() -> void:
	emit_signal("bin_complete")
	ScoreManager.add_points(50)  # Bonus
	AudioManager.play_sfx("bin_complete")
	print("[SortingBin] Bin complete! +50 bonus")

	# Auto-save progress
	SaveSystem.save_game()

	# Reset bin
	await get_tree().create_timer(1.0).timeout
	current_count = 0
	_update_label()

func _update_label() -> void:
	$Label.text = "%s Bin (%d/%d)" % [criteria_value.capitalize(), current_count, capacity]

func _flash_success() -> void:
	# Visual feedback: brief green flash on successful drop
	var bg = $Background
	var original_color = bg.color

	# Flash to light green
	var tween = create_tween()
	tween.tween_property(bg, "color", Color(0.4, 0.8, 0.4, 1.0), 0.1)
	tween.tween_property(bg, "color", original_color, 0.2)
