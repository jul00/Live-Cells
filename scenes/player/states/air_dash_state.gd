extends PlayerState

func enter():
	super()
	print("entered air dash")
	player.animator.play_dash()
	
	start_air_dash()
	player.can_airdash = false
	print("cant air dash")
	
func start_air_dash() -> void:
	await player.wait_frames(player.dash_frames)
	
	# Only transition if still in dash (safety check)
	if state_machine.current_state == self:
		state_machine.change_state(state_machine.get_node("Fall"))
	
func physics_update(delta: float):
	player.velocity.x = player.facing_direction * player.air_dash_speed
	player.velocity.y = 0
	
	if player.input_buffer.buffered_action == InputBuffer.Action.ATTACK:
		player.input_buffer.consume()
		state_machine.change_state(state_machine.get_node("AirNeutralN"))
	
	return
