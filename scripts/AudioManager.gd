extends Node
## AudioManager Singleton
## Centralized audio playback system
## Handles SFX and background music with volume controls

@onready var sfx_players: Dictionary = {}
@onready var music_player: AudioStreamPlayer = null

var master_volume: float = 0.8
var sfx_volume: float = 0.7
var music_volume: float = 0.5

# Audio file paths
const SFX_PATHS = {
	"rock_break": "res://audio/sfx/rock_break.wav",
	"mineral_collect": "res://audio/sfx/mineral_collect.wav",
	"sort_correct": "res://audio/sfx/sort_correct.wav",
	"bin_complete": "res://audio/sfx/bin_complete.wav",
	"combo": "res://audio/sfx/combo.wav"
}

const MUSIC_PATH = "res://audio/music/bgm_ambient.ogg"

func _ready() -> void:
	print("[AudioManager] Initializing audio system")
	_setup_sfx_players()
	_setup_music_player()
	_load_audio_files()

func _setup_sfx_players() -> void:
	# Create 5 AudioStreamPlayer nodes for SFX
	for sfx_name in SFX_PATHS.keys():
		var player = AudioStreamPlayer.new()
		player.name = "SFX_" + sfx_name
		player.bus = "Master"
		add_child(player)
		sfx_players[sfx_name] = player

func _setup_music_player() -> void:
	# Create music player with looping
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Master"
	add_child(music_player)

func _load_audio_files() -> void:
	# Load SFX
	for sfx_name in SFX_PATHS.keys():
		var path = SFX_PATHS[sfx_name]
		if FileAccess.file_exists(path):
			var stream = load(path)
			sfx_players[sfx_name].stream = stream
			print("[AudioManager] Loaded SFX: %s" % sfx_name)
		else:
			print("[AudioManager] WARNING: Missing SFX file: %s" % path)

	# Load music
	if FileAccess.file_exists(MUSIC_PATH):
		var stream = load(MUSIC_PATH)
		if stream is AudioStream:
			music_player.stream = stream
			# Enable looping for music (OGG files auto-loop if imported correctly)
			print("[AudioManager] Loaded music: bgm_ambient.ogg")
	else:
		print("[AudioManager] WARNING: Missing music file: %s" % MUSIC_PATH)

## Play SFX by name
func play_sfx(sfx_name: String) -> void:
	if sfx_players.has(sfx_name):
		var player = sfx_players[sfx_name]
		if player.stream != null:
			player.volume_db = _volume_to_db(master_volume * sfx_volume)
			player.play()
		# Silent if no audio file present
	else:
		print("[AudioManager] ERROR: Unknown SFX: %s" % sfx_name)

## Start background music
func play_music() -> void:
	if music_player and music_player.stream != null:
		music_player.volume_db = _volume_to_db(master_volume * music_volume)
		music_player.play()
		print("[AudioManager] Music started")

## Stop background music
func stop_music() -> void:
	if music_player:
		music_player.stop()

## Set volume levels (0.0 to 1.0)
func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func _update_volumes() -> void:
	if music_player:
		music_player.volume_db = _volume_to_db(master_volume * music_volume)

func _volume_to_db(linear: float) -> float:
	# Convert linear volume (0-1) to decibels (-80 to 0)
	if linear <= 0.0:
		return -80.0
	return linear_to_db(linear)
