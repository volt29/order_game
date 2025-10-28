extends Node
## SaveSystem Singleton
## Handles persistent data: settings, high score, stats
## Uses Godot's FileAccess API for JSON-based save files

const SAVE_PATH = "user://save_data.json"

var save_data: Dictionary = {
	"settings": {
		"master_volume": 0.8,
		"sfx_volume": 0.7,
		"music_volume": 0.5,
		"colorblind_mode": false
	},
	"progress": {
		"high_score": 0,
		"total_rocks_broken": 0,
		"total_minerals_sorted": 0,
		"total_combos": 0
	}
}

signal save_completed()
signal load_completed()

func _ready() -> void:
	print("[SaveSystem] Ready")
	load_game()

## Load save data from disk
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveSystem] No save file found, using defaults")
		apply_settings()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("[SaveSystem] Failed to open save file: " + str(FileAccess.get_open_error()))
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("[SaveSystem] Failed to parse save file JSON")
		return

	var loaded_data = json.get_data()
	if loaded_data is Dictionary:
		# Merge loaded data with defaults (in case new fields were added)
		save_data = _merge_dictionaries(save_data, loaded_data)
		print("[SaveSystem] Loaded save data from: " + SAVE_PATH)
		apply_settings()
		emit_signal("load_completed")
	else:
		push_error("[SaveSystem] Invalid save data format")

## Save data to disk
func save_game() -> void:
	# Update current settings before saving
	save_data.settings.master_volume = AudioManager.master_volume
	save_data.settings.sfx_volume = AudioManager.sfx_volume
	save_data.settings.music_volume = AudioManager.music_volume

	# Convert to JSON
	var json_string = JSON.stringify(save_data, "\t")

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SaveSystem] Failed to create save file: " + str(FileAccess.get_open_error()))
		return

	file.store_string(json_string)
	file.close()
	print("[SaveSystem] Saved game to: " + SAVE_PATH)
	emit_signal("save_completed")

## Apply loaded settings to game systems
func apply_settings() -> void:
	# Apply audio settings
	AudioManager.set_master_volume(save_data.settings.master_volume)
	AudioManager.set_sfx_volume(save_data.settings.sfx_volume)
	AudioManager.set_music_volume(save_data.settings.music_volume)
	print("[SaveSystem] Applied settings")

## Get/Set methods for easy access
func get_high_score() -> int:
	return save_data.progress.high_score

func set_high_score(score: int) -> void:
	if score > save_data.progress.high_score:
		save_data.progress.high_score = score
		save_game()
		print("[SaveSystem] New high score: %d" % score)

func increment_stat(stat_name: String, amount: int = 1) -> void:
	if save_data.progress.has(stat_name):
		save_data.progress[stat_name] += amount

func get_stat(stat_name: String) -> int:
	return save_data.progress.get(stat_name, 0)

func get_setting(setting_name: String) -> Variant:
	return save_data.settings.get(setting_name, null)

func set_setting(setting_name: String, value: Variant) -> void:
	save_data.settings[setting_name] = value
	save_game()

## Helper: Merge two dictionaries recursively (loaded overrides defaults)
func _merge_dictionaries(defaults: Dictionary, loaded: Dictionary) -> Dictionary:
	var result = defaults.duplicate(true)
	for key in loaded.keys():
		if result.has(key) and result[key] is Dictionary and loaded[key] is Dictionary:
			result[key] = _merge_dictionaries(result[key], loaded[key])
		else:
			result[key] = loaded[key]
	return result
