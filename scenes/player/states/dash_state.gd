extends PlayerState

func enter():
	super()
	print("entered dash")
	player.animator.play_dash()
	
	start_dash()
	
func start_dash() -> void:
	await player.wait_frames(player.dash_frames)
	
	# Only transition if still in dash (safety check)
	if state_machine.current_state == self:
		state_machine.change_state(state_machine.get_node("Skid"))

func physics_update(delta: float):
	player.velocity.x = player.facing_direction * player.dash_speed
	player.velocity.y = 0
	
	if not player.is_on_floor():
		state_machine.change_state(state_machine.get_node("Fall"))
		return
