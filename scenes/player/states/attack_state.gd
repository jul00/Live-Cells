extends "res://scenes/player/player_state.gd"

func enter():
	super()
	print("entered attack")
	player.attack_handler.request_attack()
	wait_for_attack_end()

func wait_for_attack_end():
	while player.attack_handler.is_busy():
		await get_tree().physics_frame
		
	if player.is_on_floor():
		state_machine.change_state(state_machine.get_node("Idle"))
	else:
		state_machine.change_state(state_machine.get_node("Fall"))
