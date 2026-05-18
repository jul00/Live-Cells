extends PlayerState

func enter():
	super()
	print("entered jump")
	player.animator.play_jump()
	print("can air dash")
	player.can_airdash = true
	
func physics_update(delta: float):
	player.velocity += player.get_gravity() * delta
	
	if player.input_handler.dash_pressed() and player.can_airdash:
		state_machine.change_state(state_machine.get_node("AirDash"))
		return
	
	if player.input_handler.jump_released() and player.velocity.y < 0: # short hop
		player.velocity.y = player.jump_velocity / 20
	
<<<<<<< Updated upstream
	if player.input_handler.attack_pressed():
		state_machine.change_state(state_machine.get_node("AttackHandler"))
		return
=======
	if player.input_buffer.buffered_action == InputBuffer.Action.ATTACK:
		player.input_buffer.consume()
		state_machine.change_state(state_machine.get_node("AirNeutralN"))
>>>>>>> Stashed changes
		
	if player.velocity.y > 0:
		state_machine.change_state(state_machine.get_node("JumpTransition"))
		return
