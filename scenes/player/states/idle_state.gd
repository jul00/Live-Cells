extends PlayerState

func enter():
	super()
	print("entered idle")
	player.animator.play_idle()
	
func physics_update(delta: float):
	var direction = player.input_handler.get_move_direction()
	player.velocity.x = 0
	
	if not player.is_on_floor():
		state_machine.change_state(state_machine.get_node("Fall"))
		return
	
	if direction != 0:
		state_machine.change_state(state_machine.get_node("Run"))
		return
	
	if player.input_handler.attack_pressed():
		state_machine.change_state(state_machine.get_node("Attack"))
		return

	if player.input_handler.jump_pressed():
		player.velocity.y = player.jump_velocity
		state_machine.change_state(state_machine.get_node("Jump"))
		return
	
	if player.input_handler.dash_pressed():
		state_machine.change_state(state_machine.get_node("Dash"))
		return
