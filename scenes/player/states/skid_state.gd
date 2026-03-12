extends "res://scenes/player/player_state.gd"

func enter():
	super()
	print("entered skid")
	player.animator.play_skid()
	
func physics_update(delta: float) -> void:
	var direction = player.input_handler.get_move_direction()
	player.velocity.x = move_toward(player.velocity.x, 0, player.ground_friction * delta)
	
	
	if direction != 0:
		state_machine.change_state(state_machine.get_node("Run"))
	
	if abs(player.velocity.x) < 5:
		player.velocity.x = 0
		state_machine.change_state(state_machine.get_node("Idle"))
		return
	
	elif player.input_handler.jump_pressed():
		player.velocity.y = player.jump_velocity
		state_machine.change_state(state_machine.get_node("Jump"))
