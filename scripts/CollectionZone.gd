extends Area2D
## CollectionZone - follows cursor, auto-collects resting minerals
## AC 3.1: Auto-Collect Radius (100px)

func _process(_delta: float) -> void:
	# Follow mouse cursor
	global_position = get_global_mouse_position()

func _on_area_entered(area: Area2D) -> void:
	# Check if it's a Mineral (has parent RigidBody2D)
	var mineral = area.get_parent()
	if mineral is RigidBody2D and mineral.has_method("init"):
		# AC 3.1: Only collect resting minerals
		if mineral.is_resting:
			collect_mineral(mineral)

func collect_mineral(mineral: RigidBody2D) -> void:
	# AC 3.3: Collection Feedback (tween to cursor, then destroy)
	var tween = create_tween()
	tween.tween_property(mineral, "global_position", global_position, 0.3)
	tween.tween_callback(func(): _on_mineral_collected(mineral))

func _on_mineral_collected(mineral: RigidBody2D) -> void:
	# Add to inventory
	InventoryManager.add_mineral(mineral.mineral_id, 1)

	# TODO: Play SFX "mineral_collect.wav"

	# Destroy mineral
	mineral.queue_free()
