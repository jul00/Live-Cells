extends Node
class_name InputBuffer

enum Action {
	NONE,
	JUMP,
	ATTACK,
	DASH,
	SPECIAL
}

var buffer_frames = 8

var buffered_action : Action = Action.NONE
var buffer_timer = 0

var horizontal = 0
var vertical = 0

func store(action, h, v):

	buffered_action = action
	horizontal = h
	vertical = v
	buffer_timer = buffer_frames

func capture_inputs(input_handler):
	var h = input_handler.get_move_direction()
	var v = input_handler.get_vertical_direction()

	if input_handler.attack_pressed():
		store(Action.ATTACK, h, v)

	if input_handler.jump_pressed():
		store(Action.JUMP, h, v)

	if input_handler.dash_pressed():
		store(Action.DASH, h, v)

func update():
	if buffer_timer > 0:
		buffer_timer -= 1

	if buffer_timer <= 0:
		buffered_action = Action.NONE

func consume():
	buffered_action = Action.NONE
	buffer_timer = 0
