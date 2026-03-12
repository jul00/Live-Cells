extends "res://scenes/player/player_state.gd"

func enter():
	super()
	print("entered jump")
	player.animator.play_jump()
	
func physics_update(delta: float):
	player.velocity += player.get_gravity() * delta
	
	if player.input_handler.dash_pressed():
		state_machine.change_state(state_machine.get_node("AirDash"))
		return
	
	if player.input_handler.jump_released() and player.velocity.y < 0: # short hop
		player.velocity.y = player.jump_velocity / 20
	
	if player.input_handler.attack_pressed():
		state_machine.change_state(state_machine.get_node("Attack"))
		return
		
	if player.velocity.y > 0:
		state_machine.change_state(state_machine.get_node("Fall"))
		return
