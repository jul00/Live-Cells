extends Node

func get_move_direction() -> float:
	return Input.get_axis("move_left", "move_right")

func jump_pressed() -> bool:
	return Input.is_action_just_pressed("jump")
	
func jump_released() -> bool:
	return Input.is_action_just_released("jump")

func attack_pressed() -> bool:
	return Input.is_action_just_pressed("normal-attack")
