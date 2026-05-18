extends Node

# Dictionary containing paths to audio streams
var libs: Dictionary = {
	"hit": [
		"res://assets/SFX/cut1.mp3",
		"res://assets/SFX/cut2.mp3",
		"res://assets/SFX/cut3.mp3"
	],
	"block": [
		"res://assets/SFX/block1.mp3",
		"res://assets/SFX/block2.mp3",
		"res://assets/SFX/block3.mp3",
		"res://assets/SFX/block4.mp3"
	],
	"dash": ["res://assets/SFX/dash.mp3"],
	"item_spawn": ["res://assets/SFX/item_drop.wav"],
	"item_collect": ["res://assets/SFX/item_pickup.wav"],
	"bg_music": ["res://assets/SFX/bg_music.mp3"],
	"footstep": ["res://assets/SFX/step.mp3"],
	"bow_draw": ["res://assets/SFX/draw_bow.mp3"],
	"bow_shoot": ["res://assets/SFX/shoot_arrow.mp3"],
	"shout": ["res://assets/SFX/shout.mp3"]
}

# Preloaded streams
var streams: Dictionary = {}

# Pool of AudioStreamPlayers
var players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
const POOL_SIZE = 16

@export_group("Hit Sound Settings")
@export var hit_pitch_scale: float = 1.0
@export var hit_volume_db: float = 0.0

@export_group("Block Sound Settings")
@export var block_pitch_scale: float = 1.2
@export var block_volume_db: float = 1.0
@export var block_start_offset: float = 0.3

@export_group("Movement Settings")
@export var dash_pitch_scale: float = 1.0
@export var dash_volume_db: float = -10.0
@export var footstep_pitch_scale: float = 1.0
@export var footstep_volume_db: float = -10.0

@export_group("Weapon Settings")
@export var bow_draw_pitch_scale: float = 1.0
@export var bow_draw_volume_db: float = -5.0
@export var bow_shoot_pitch_scale: float = 1.0
@export var bow_shoot_volume_db: float = 0.0

@export_group("Character Settings")
@export var boss_shout_pitch_scale: float = 0.8
@export var boss_shout_volume_db: float = 5.0

@export_group("Item Settings")
@export var item_spawn_volume_db: float = -5.0
@export var item_collect_volume_db: float = 0.0

@export_group("Music Settings")
@export var music_volume_db: float = -25.0

func _ready() -> void:
	# Ensure sounds play even when the game is paused
	process_mode = PROCESS_MODE_ALWAYS
	
	# Preload all streams using load()
	for lib_name in libs:
		streams[lib_name] = []
		for path in libs[lib_name]:
			var s = load(path)
			if s:
				if (lib_name == "bg_music" or lib_name == "footstep") and s is AudioStreamMP3:
					s.loop = true
				streams[lib_name].append(s)
			else:
				push_error("AudioManager: Failed to load sound at " + path)
	
	# Initialize the player pool
	for i in range(POOL_SIZE):
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		players.append(asp)
		
	# Initialize music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Start BG Music by default
	play_music("bg_music")

## Plays a random sound effect from the specified library with pitch randomization.
func play_sfx(lib_name: String, p_min: float = 0.9, p_max: float = 1.1) -> void:
	if not streams.has(lib_name):
		push_warning("AudioManager: Library '%s' not found." % lib_name)
		return
	
	var stream_list: Array = streams[lib_name]
	if stream_list.is_empty():
		return
		
	var random_stream = stream_list.pick_random()
	
	var player = _get_available_player()
	if not player:
		player = players.pick_random()
	
	if player:
		player.stream = random_stream
		
		# Apply individual global modifiers
		var final_pitch_min = p_min
		var final_pitch_max = p_max
		var final_volume = 0.0
		
		match lib_name:
			"hit":
				final_pitch_min *= hit_pitch_scale
				final_pitch_max *= hit_pitch_scale
				final_volume = hit_volume_db
			"block":
				final_pitch_min *= block_pitch_scale
				final_pitch_max *= block_pitch_scale
				final_volume = block_volume_db
			"dash":
				final_pitch_min *= dash_pitch_scale
				final_pitch_max *= dash_pitch_scale
				final_volume = dash_volume_db
			"footstep":
				final_pitch_min *= footstep_pitch_scale
				final_pitch_max *= footstep_pitch_scale
				final_volume = footstep_volume_db
			"bow_draw":
				final_pitch_min *= bow_draw_pitch_scale
				final_pitch_max *= bow_draw_pitch_scale
				final_volume = bow_draw_volume_db
			"bow_shoot":
				final_pitch_min *= bow_shoot_pitch_scale
				final_pitch_max *= bow_shoot_pitch_scale
				final_volume = bow_shoot_volume_db
			"shout":
				final_pitch_min *= boss_shout_pitch_scale
				final_pitch_max *= boss_shout_pitch_scale
				final_volume = boss_shout_volume_db
			"item_spawn":
				final_volume = item_spawn_volume_db
			"item_collect":
				final_volume = item_collect_volume_db
				
		player.pitch_scale = randf_range(final_pitch_min, final_pitch_max)
		player.volume_db = final_volume
		
		if lib_name == "block":
			player.play(block_start_offset)
		else:
			player.play()

## Stops any active sounds from the specified library.
func stop_sfx(lib_name: String) -> void:
	if not streams.has(lib_name):
		return
		
	var stream_list: Array = streams[lib_name]
	for p in players:
		if p.playing and p.stream in stream_list:
			p.stop()

func play_music(lib_name: String):
	if not streams.has(lib_name) or streams[lib_name].is_empty():
		return
	
	music_player.stream = streams[lib_name][0]
	music_player.volume_db = music_volume_db
	music_player.play()

func is_playing(lib_name: String) -> bool:
	if not streams.has(lib_name) or streams[lib_name].is_empty():
		return false
	
	for stream in streams[lib_name]:
		for p in players:
			if p.playing and p.stream == stream:
				return true
	return false

func _get_available_player() -> AudioStreamPlayer:
	for p in players:
		if not p.playing:
			return p
	return null
