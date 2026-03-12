extends PlayerState

func enter():
	super()
	print("entered fall")
	player.animator.play_fall()
	
func physics_update(delta: float):
	var move_direction = player.input_handler.get_move_direction()
	var vertical_direction = player.input_handler.get_vertical_direction()
	
	player.velocity += player.get_gravity() * delta
	
	if player.input_handler.dash_pressed():
		state_machine.change_state(state_machine.get_node("AirDash"))
		return
	
	if vertical_direction == 1:
		player.velocity.y = player.fastfall_velocity
	
	player.velocity.x = move_toward( # air movement
		player.velocity.x,
		move_direction * player.air_max_speed,
		player.air_accel * delta
	)
	
	if player.input_handler.attack_pressed():
		state_machine.change_state(state_machine.get_node("AttackHandler"))
		return
		
	if player.is_on_floor():
		state_machine.change_state(state_machine.get_node("Land"))
