extends "res://scenes/player/player_state.gd"

func enter():
	super()
	print("entered dash")
	player.animator.play_dash()

func physics_update(delta: float):
	player.velocity.x = player.facing_direction * player.dash_speed
	player.velocity.y = 0
	
	await player.wait_frames(player.dash_frames)
	
	if player.is_on_floor():
		var move_input = player.input_handler.get_move_direction()
		if move_input != 0:
			player.facing_direction = move_input
			state_machine.change_state(state_machine.get_node("Run"))
		else:
			state_machine.change_state(state_machine.get_node("Skid"))
	else:
		state_machine.change_state(state_machine.get_node("Fall"))
		return
	
	return
