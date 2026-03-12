extends Node
class_name PlayerState

var player
var state_machine
	
func enter():
	if player == null:
		state_machine = get_parent()
		player = state_machine.get_parent()
		
func exit():
	pass

func physics_update(delta):
	pass
