extends PlayerState

@export var frame_data : AttackFrameData

func enter():
	super()
	player.animator.play_norm3()
	print("entered attack 3")
	player.hitbox.monitoring = false
	player.hitbox.reset()
	
func physics_update(delta):
	player.velocity.x = 0
	var frame = player.animator.get_sprite().frame

	if frame >= frame_data.active_frames.x and frame <= frame_data.active_frames.y:
		player.hitbox.monitoring = true
		#if player.hitbox.monitoring:
			#print("hitbox monitoring on")
	else:
		player.hitbox.monitoring = false
		#if not player.hitbox.monitoring:
			#print("hitbox monitoring off")
		
	if frame >= frame_data.recovery_frames.y:
		state_machine.change_state(state_machine.get_node("Idle"))
