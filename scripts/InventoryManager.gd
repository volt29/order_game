extends Node
## InventoryManager Singleton
## Tracks collected mineral counts
## Usage: InventoryManager.add_mineral("ruby_small", 1)

var inventory: Dictionary = {}  # { "ruby_small": 5, "sapphire_small": 3, ... }

signal inventory_changed(mineral_id: String, count: int)

func _ready() -> void:
	print("[InventoryManager] Ready")

func add_mineral(mineral_id: String, amount: int = 1) -> void:
	if not inventory.has(mineral_id):
		inventory[mineral_id] = 0
	inventory[mineral_id] += amount
	emit_signal("inventory_changed", mineral_id, inventory[mineral_id])
	print("[InventoryManager] Added %d × %s (total: %d)" % [amount, mineral_id, inventory[mineral_id]])

func remove_mineral(mineral_id: String, amount: int = 1) -> bool:
	if inventory.get(mineral_id, 0) >= amount:
		inventory[mineral_id] -= amount
		emit_signal("inventory_changed", mineral_id, inventory[mineral_id])
		return true
	return false

func get_count(mineral_id: String) -> int:
	return inventory.get(mineral_id, 0)

func clear() -> void:
	inventory.clear()
	print("[InventoryManager] Inventory cleared")
