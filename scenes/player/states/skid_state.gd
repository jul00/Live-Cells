extends PlayerState

func enter():
	super()
	print("entered skid")
	player.animator.play_skid()
	
func physics_update(delta: float) -> void:
	var direction = player.input_handler.get_move_direction()
	player.velocity.x = move_toward(player.velocity.x, 0, player.ground_friction * delta)
	
	if player.input_buffer.buffered_action == InputBuffer.Action.ATTACK:
		player.input_buffer.consume()
		state_machine.change_state(state_machine.get_node("AttackHandler"))
	
	elif player.input_handler.jump_pressed():
		player.velocity.y = player.jump_velocity
		state_machine.change_state(state_machine.get_node("Jump"))
	
	if abs(player.velocity.x) < 10:
		player.velocity.x = 0
		state_machine.change_state(state_machine.get_node("Idle"))
		return
	
	if direction != 0:
		state_machine.change_state(state_machine.get_node("Run"))
		return
	
