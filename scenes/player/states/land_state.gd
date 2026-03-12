extends "res://scenes/player/player_state.gd"

func enter():
	super()
	print("entered land")
	player.animator.play_land()
	
func physics_update(delta: float):
	player.velocity.x = move_toward(player.velocity.x, 0, player.ground_friction * delta)
	
	await player.wait_frames(player.land_frames)
	
	state_machine.change_state(state_machine.get_node("Idle"))
