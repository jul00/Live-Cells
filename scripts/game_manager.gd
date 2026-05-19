# scripts/game_manager.gd
extends Node

enum State { START, PLAYING, GAME_OVER, VICTORY }

signal state_changed(new_state: State)

var current_state: State = State.START

func _ready() -> void:
	# Ensure GameManager processes even when paused
	process_mode = PROCESS_MODE_ALWAYS
	
	# Try to ensure MCPRuntime (if present) also processes always
	var mcp = get_node_or_null("/root/MCPRuntime")
	if mcp:
		mcp.process_mode = PROCESS_MODE_ALWAYS
	
	# Start in the START state
	call_deferred("change_state", State.START)

func change_state(new_state: State) -> void:
	current_state = new_state
	
	match current_state:
		State.START:
			get_tree().paused = true
		State.PLAYING:
			get_tree().paused = false
		State.GAME_OVER:
			get_tree().paused = true
		State.VICTORY:
			get_tree().paused = true
	
	state_changed.emit(current_state)

func start_game() -> void:
	change_state(State.PLAYING)

func game_over() -> void:
	if current_state != State.GAME_OVER:
		change_state(State.GAME_OVER)

func win_game() -> void:
	if current_state != State.VICTORY:
		change_state(State.VICTORY)

func restart_game() -> void:
	# Transition back to START or directly to PLAYING
	# For most arcade games, we reload and go to START
	get_tree().paused = false # Unpause briefly to allow reload
	get_tree().reload_current_scene()
	change_state(State.START)
