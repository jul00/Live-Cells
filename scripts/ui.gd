# scripts/ui.gd
extends CanvasLayer

@onready var game_hud = $GameHUD
@onready var start_menu = $StartMenu
@onready var game_over_menu = $GameOverMenu
@onready var victory_menu = $VictoryMenu
@onready var fade_overlay = $FadeOverlay

@onready var play_button = $StartMenu/VBoxContainer/PlayButton
@onready var restart_button = $GameOverMenu/VBoxContainer/RestartButton
@onready var win_restart_button = $VictoryMenu/VBoxContainer/RestartButton

func _ready() -> void:
	# UI must always process to handle menu interaction
	process_mode = PROCESS_MODE_ALWAYS
	
	# Connect to GameManager signals
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.state_changed.connect(_on_game_state_changed)
		_on_game_state_changed(gm.current_state)
	
	# Connect Button signals
	play_button.pressed.connect(_on_play_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	win_restart_button.pressed.connect(_on_restart_pressed)

func _on_game_state_changed(new_state: GameManager.State) -> void:
	# Toggle visibility based on state
	start_menu.visible = (new_state == GameManager.State.START)
	game_hud.visible = (new_state == GameManager.State.PLAYING)
	game_over_menu.visible = (new_state == GameManager.State.GAME_OVER)
	victory_menu.visible = (new_state == GameManager.State.VICTORY)

func _on_play_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.start_game()

func _on_restart_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.restart_game()

func fade_to_black(duration: float = 0.5) -> Signal:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_overlay, "modulate:a", 1.0, duration)
	return tween.finished

func fade_from_black(duration: float = 0.5) -> Signal:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_overlay, "modulate:a", 0.0, duration)
	return tween.finished
