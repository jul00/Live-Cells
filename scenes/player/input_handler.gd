extends Node

# Reference to the main player script
@onready var player = get_parent()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("normal-attack"):
		player.handle_attack_input()
		
	if event.is_action_pressed("jump"):
		player.handle_jump_input()
	
	if event.is_action_released("jump"):
		player.handle_jump_release()

func _physics_process(_delta: float) -> void:
	# Get movement axis and pass it to the player
	var direction = Input.get_axis("move_left", "move_right")
	player.set_move_direction(direction)
