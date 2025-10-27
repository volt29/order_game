extends Node
## DataLoader Singleton
## Loads JSON config files (minerals, rocks) at runtime.
## Usage: DataLoader.minerals["ruby_small"].name

var minerals: Dictionary = {}
var rocks: Dictionary = {}

func _ready() -> void:
	load_minerals()
	load_rocks()
	print("[DataLoader] Loaded %d minerals, %d rocks" % [minerals.size(), rocks.size()])

func load_minerals() -> void:
	var file_path = "res://data/minerals.json"
	if not FileAccess.file_exists(file_path):
		push_error("[DataLoader] minerals.json not found!")
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		push_error("[DataLoader] Failed to parse minerals.json: " + json.get_error_message())
		return

	var data = json.get_data()
	if not data.has("minerals"):
		push_error("[DataLoader] minerals.json missing 'minerals' key")
		return

	for mineral in data.minerals:
		minerals[mineral.id] = mineral

func load_rocks() -> void:
	var file_path = "res://data/rocks.json"
	if not FileAccess.file_exists(file_path):
		push_error("[DataLoader] rocks.json not found!")
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		push_error("[DataLoader] Failed to parse rocks.json: " + json.get_error_message())
		return

	var data = json.get_data()
	if not data.has("rocks"):
		push_error("[DataLoader] rocks.json missing 'rocks' key")
		return

	for rock in data.rocks:
		rocks[rock.id] = rock

func get_mineral(mineral_id: String) -> Dictionary:
	if minerals.has(mineral_id):
		return minerals[mineral_id]
	push_warning("[DataLoader] Mineral not found: " + mineral_id)
	return {}

func get_rock(rock_id: String) -> Dictionary:
	if rocks.has(rock_id):
		return rocks[rock_id]
	push_warning("[DataLoader] Rock not found: " + rock_id)
	return {}
