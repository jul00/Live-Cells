extends PlayerState

func enter():
	super()
	print("entered attack handler")
	var direction =  player.input_buffer.horizontal
	var vertical = player.input_buffer.vertical
	print(vertical)
	
	if player.is_on_floor() and vertical < 0:
		state_machine.change_state(state_machine.get_node("GroundUpN"))
	elif player.is_on_floor() and direction == 0: 
		state_machine.change_state(state_machine.get_node("GroundNeutralN1"))
	elif not player.is_on_floor() and direction == 0:
		state_machine.change_state(state_machine.get_node("AirNeutralN"))


	
	
