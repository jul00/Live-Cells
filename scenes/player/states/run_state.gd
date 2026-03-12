extends PlayerState

func enter():
	super()
	print("entered run")
	player.animator.play_run()
	
func physics_update(delta: float) -> void:
	var direction = player.input_handler.get_move_direction()
	if player.is_on_floor():
		if direction == 0 and abs(player.velocity.x) > 0:  
			state_machine.change_state(state_machine.get_node("Skid"))
			return
		
		player.velocity.x = direction * player.movespeed
		
		if player.velocity.x == 0:
			state_machine.change_state(state_machine.get_node("Idle"))
			return
		
		player.facing_direction = direction
		player.animator.set_facing(direction)
	else:
		state_machine.change_state(state_machine.get_node("Fall"))
		return
	
	if player.input_handler.attack_pressed():
		state_machine.change_state(state_machine.get_node("Attack"))
		return
	
	if player.input_handler.jump_pressed():
		player.velocity.y = player.jump_velocity
		state_machine.change_state(state_machine.get_node("Jump"))
		return
