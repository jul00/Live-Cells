extends PlayerState

@export var frame_data : AttackFrameData

func enter():
	super()
	player.animator.play_norm1()
	player.hitbox.monitoring = false
	player.hitbox.reset()
	
func physics_update(delta):
	player.velocity.x = 0
	var frame = player.animator.get_sprite().frame

	if frame in frame_data.active_frames:
		player.hitbox.monitoring = true
		#if player.hitbox.monitoring:
			#print("hitbox monitoring on")
	else:
		player.hitbox.monitoring = false
		#if not player.hitbox.monitoring:
			#print("hitbox monitoring off")
	if frame <= frame_data.recovery_frames.max() and player.input_handler.attack_pressed():
		state_machine.change_state(state_machine.get_node("GroundNeutralN2"))
		
	if frame >= frame_data.recovery_frames.max():
		state_machine.change_state(state_machine.get_node("Idle"))
