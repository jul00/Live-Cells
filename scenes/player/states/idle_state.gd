extends PlayerState

func enter():
	super()
	print("entered idle")
	player.hitbox.monitoring = false
	player.animator.play_idle()


func physics_update(delta: float):

	var direction = player.input_handler.get_move_direction()
	var action = player.input_buffer.buffered_action

	player.velocity.x = 0

	if not player.is_on_floor():
		state_machine.change_state(state_machine.get_node("Fall"))
		return


	# Handle buffered actions
	match action:

		InputBuffer.Action.ATTACK:
			player.input_buffer.consume()
			state_machine.change_state(state_machine.get_node("AttackHandler"))
			return

		InputBuffer.Action.JUMP:
			player.input_buffer.consume()
			player.velocity.y = player.jump_velocity
			state_machine.change_state(state_machine.get_node("Jump"))
			return

		InputBuffer.Action.DASH:
			player.input_buffer.consume()
			state_machine.change_state(state_machine.get_node("Dash"))
			return


	if direction != 0:
		state_machine.change_state(state_machine.get_node("Run"))
