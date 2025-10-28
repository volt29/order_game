extends Control
## SettingsMenu - UI for game settings
## AC 7.1: Settings accessible via ESC key
## AC 7.2: Volume controls (Master, SFX, Music)
## AC 7.3: Colorblind mode toggle

@onready var master_slider = $Panel/VBoxContainer/MasterVolumeSlider
@onready var sfx_slider = $Panel/VBoxContainer/SFXVolumeSlider
@onready var music_slider = $Panel/VBoxContainer/MusicVolumeSlider
@onready var colorblind_checkbox = $Panel/VBoxContainer/ColorblindModeContainer/ColorblindModeCheckbox

var is_open: bool = false

func _ready() -> void:
	# Load settings from SaveSystem
	_load_settings()

	# AC 7.1: Listen for ESC key to toggle menu
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_menu()

func toggle_menu() -> void:
	is_open = !is_open
	visible = is_open

	if is_open:
		# Pause game when settings open
		get_tree().paused = true
	else:
		# Unpause game when settings close
		get_tree().paused = false
		# Save settings when closing
		SaveSystem.save_game()

func _load_settings() -> void:
	# Load volume settings
	master_slider.value = SaveSystem.save_data.settings.master_volume
	sfx_slider.value = SaveSystem.save_data.settings.sfx_volume
	music_slider.value = SaveSystem.save_data.settings.music_volume
	colorblind_checkbox.button_pressed = SaveSystem.save_data.settings.colorblind_mode

## AC 7.2: Volume control callbacks
func _on_master_volume_changed(value: float) -> void:
	AudioManager.set_master_volume(value)
	SaveSystem.save_data.settings.master_volume = value

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	SaveSystem.save_data.settings.sfx_volume = value
	# Play test sound
	AudioManager.play_sfx("mineral_collect")

func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value)
	SaveSystem.save_data.settings.music_volume = value

## AC 7.3: Colorblind mode toggle
func _on_colorblind_mode_toggled(enabled: bool) -> void:
	SaveSystem.save_data.settings.colorblind_mode = enabled
	# TODO: Apply colorblind mode visual changes (e.g., stronger shape emphasis)
	print("[SettingsMenu] Colorblind mode: %s" % ("ON" if enabled else "OFF"))

func _on_close_button_pressed() -> void:
	toggle_menu()
