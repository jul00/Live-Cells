extends "res://scenes/player/player_state.gd"

func enter():
	super()
	print("entered air dash")
	player.animator.play_dash()

func physics_update(delta: float):
	player.velocity.x = player.facing_direction * player.air_dash_speed
	player.velocity.y = 0
	
	await player.wait_frames(player.dash_frames)
	state_machine.change_state(state_machine.get_node("Fall"))
	
	return
