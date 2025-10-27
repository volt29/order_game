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

func _on_button_pressed() -> void:
	# Placeholder: "Sort" the first matching mineral from inventory
	# AC 4.1: In full version, this would be drag-drop
	var sorted = _try_sort_from_inventory()
	if sorted:
		print("[SortingBin] Sorted %s to %s bin" % [sorted, criteria_value])

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
	print("[SortingBin] Bin complete! +50 bonus")
	# Reset bin
	await get_tree().create_timer(1.0).timeout
	current_count = 0
	_update_label()

func _update_label() -> void:
	$Label.text = "%s Bin (%d/%d)" % [criteria_value.capitalize(), current_count, capacity]
