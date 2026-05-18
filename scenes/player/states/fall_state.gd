extends PlayerState

var can_airdash: bool

func enter():
	super()
	can_airdash = true
	player.animator.play_fall()
	
func physics_update(delta: float):
	var move_direction = player.input_handler.get_move_direction()
	var vertical_direction = player.input_handler.get_vertical_direction()
	
	player.velocity += player.get_gravity() * delta
	
	if player.input_handler.dash_pressed() and player.can_airdash: 
		state_machine.change_state(state_machine.get_node("AirDash"))
		return
	
	player.velocity.x = move_toward( # air movement
		player.velocity.x,
		move_direction * player.air_max_speed,
		player.air_accel * delta
	)
	
	if player.input_buffer.buffered_action == InputBuffer.Action.ATTACK:
		player.input_buffer.consume()
		state_machine.change_state(state_machine.get_node("AirNeutralN"))
		
	if player.is_on_floor():
		state_machine.change_state(state_machine.get_node("Land"))
