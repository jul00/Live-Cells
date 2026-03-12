extends PlayerState

func enter():
	super()
	var direction = player.input_handler.get_move_direction()
	
	if player.is_on_floor():
		state_machine.change_state(state_machine.get_node("GroundNeutralN1"))


	
	
