# scripts/ui.gd
extends CanvasLayer

@onready var game_hud = $GameHUD
@onready var start_menu = $StartMenu
@onready var game_over_menu = $GameOverMenu
@onready var victory_menu = $VictoryMenu

@onready var play_button = $StartMenu/VBoxContainer/PlayButton
@onready var restart_button = $GameOverMenu/VBoxContainer/RestartButton
@onready var win_restart_button = $VictoryMenu/VBoxContainer/RestartButton

func _ready() -> void:
	# UI must always process to handle menu interaction
	process_mode = PROCESS_MODE_ALWAYS
	
	# Connect to GameManager signals
	if GameManager:
		GameManager.state_changed.connect(_on_game_state_changed)
		_on_game_state_changed(GameManager.current_state)
	
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
	if GameManager:
		GameManager.start_game()

func _on_restart_pressed() -> void:
	if GameManager:
		GameManager.restart_game()
