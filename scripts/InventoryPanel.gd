extends Control
## InventoryPanel UI - displays collected minerals
## AC 10.1: Inventory Display (icon + count)

@onready var mineral_list = $MineralList

var mineral_labels: Dictionary = {}  # { "ruby_small": Label, ... }

func _ready() -> void:
	InventoryManager.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(mineral_id: String, count: int) -> void:
	# AC 10.1: Show mineral icon + count
	if not mineral_labels.has(mineral_id):
		# Create new label for this mineral
		var label = Label.new()
		label.name = mineral_id
		mineral_list.add_child(label)
		mineral_labels[mineral_id] = label

	# Update label text
	var mineral_data = DataLoader.get_mineral(mineral_id)
	var mineral_name = mineral_data.get("name", mineral_id)
	var color_hex = mineral_data.get("color_hex", "#FFFFFF")

	mineral_labels[mineral_id].text = "[%s] %s  ×%d" % [color_hex, mineral_name, count]

	# Remove label if count is 0
	if count == 0:
		mineral_labels[mineral_id].queue_free()
		mineral_labels.erase(mineral_id)
