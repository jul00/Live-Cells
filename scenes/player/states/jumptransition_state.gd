extends PlayerState

var frame_count := 0
const MAX_FRAMES := 6   # number of frames before switching to fall


func enter() -> void:
	super()
	frame_count = 0
	print("entered jump transition")

func physics_update(delta: float):
	frame_count += 1
	
	var vertical_direction = player.input_handler.get_vertical_direction()
	player.velocity += player.get_gravity() * delta
	
	if player.input_handler.dash_pressed() and player.can_airdash:
		state_machine.change_state(state_machine.get_node("AirDash"))
		return
	
	if not player.is_on_floor() and player.input_buffer.buffered_action == InputBuffer.Action.ATTACK:
		player.input_buffer.consume()
		state_machine.change_state(state_machine.get_node("AirNeutralN"))
	
	if vertical_direction == 1:
		player.velocity.y = player.fastfall_velocity
	
	if frame_count >= MAX_FRAMES:
		state_machine.change_state(state_machine.get_node("Fall"))
		return
