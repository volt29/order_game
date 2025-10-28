extends Control
## InventoryPanel UI - displays collected minerals with drag-drop support
## AC 10.1: Inventory Display (icon + count)
## AC 10.2: Drag from Inventory (UPDATED)

@onready var mineral_list = $MineralList

var mineral_items: Dictionary = {}  # { "ruby_small": MineralItem, ... }

func _ready() -> void:
	InventoryManager.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(mineral_id: String, count: int) -> void:
	# AC 10.1: Show mineral icon + count
	if not mineral_items.has(mineral_id):
		# Create new draggable item for this mineral
		var item = MineralInventoryItem.new()
		item.mineral_id = mineral_id
		item.name = mineral_id
		mineral_list.add_child(item)
		mineral_items[mineral_id] = item

	# Update item
	mineral_items[mineral_id].update_count(count)

	# Remove item if count is 0
	if count == 0:
		mineral_items[mineral_id].queue_free()
		mineral_items.erase(mineral_id)


## MineralInventoryItem - Draggable control for a single mineral type
class MineralInventoryItem extends Control:
	var mineral_id: String = ""
	var count: int = 0

	var label: Label

	func _ready() -> void:
		custom_minimum_size = Vector2(200, 30)

		# Create label
		label = Label.new()
		label.anchors_preset = Control.PRESET_FULL_RECT
		add_child(label)

		# Enable mouse filter for drag detection
		mouse_filter = Control.MOUSE_FILTER_STOP

	func update_count(new_count: int) -> void:
		count = new_count
		var mineral_data = DataLoader.get_mineral(mineral_id)
		var mineral_name = mineral_data.get("name", mineral_id)
		var color_hex = mineral_data.get("color_hex", "#FFFFFF")
		label.text = "[%s] %s  ×%d" % [color_hex, mineral_name, count]

	func _get_drag_data(_at_position: Vector2) -> Variant:
		# AC 10.2: Drag from Inventory
		if count <= 0:
			return null

		# Create drag preview (simple label)
		var preview = Label.new()
		var mineral_data = DataLoader.get_mineral(mineral_id)
		preview.text = mineral_data.get("name", mineral_id)
		preview.modulate = Color(1, 1, 1, 0.7)
		set_drag_preview(preview)

		# Return mineral_id as drag data
		return mineral_id
