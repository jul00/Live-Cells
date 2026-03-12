extends Node

@onready var player = get_parent()
@onready var animator = player.get_node("PlayerAnimator")
@onready var input_handler = player.get_node("PlayerInput")

# States
var is_ground_attacking = false
var is_air_attacking = false
var is_recovering = false
var can_chain = false
var combo_queued = false
var combo_step = 0
var air_combo_step = 0
var is_dash_attacking = false

# Frame data, default given here, can be changed per attack in their respective functions, 
const DEFAULT_SLIDE_FRAME = 0
const DEFAULT_COMBO_WINDOW = 60
const DEFAULT_RECOVERY = 10

var slide_frame = DEFAULT_SLIDE_FRAME
var combo_window_frames = DEFAULT_COMBO_WINDOW
var recovery_frames = DEFAULT_RECOVERY

# Stats
var attack_slide_speed = 50.0
var attack_slide_time = 0.15
var attack_slide_multiplier = 1

func request_attack():
	var horizontal = input_handler.get_move_direction()
	var vertical = input_handler.get_vertical_direction()

	handle_attack_input(horizontal, vertical)

func handle_attack_input(horizontal, vertical):
	if player.is_on_floor():
		handle_ground_attack(horizontal, vertical)
		
	else:
		handle_air_attack(horizontal, vertical)

func handle_ground_attack(horizontal, vertical):
	if is_recovering:
		return

	if not is_ground_attacking:
		if abs(horizontal) > 0.5:
			start_forward_attack(1)
		elif vertical == -1:
			start_neutral_normal_up_attack(horizontal)
		else:
			start_neutral_attack()
			
	elif can_chain and combo_step < 3:
		combo_queued = true
		
func handle_air_attack(horizontal, vertical):
	if is_recovering:
		return

	if not is_air_attacking:
		if vertical > 0.5:
			start_air_normal_down_attack(horizontal)
			pass
		
		elif vertical < -0.5:
			start_air_normal_up_attack(horizontal)
			pass

		elif abs(horizontal) > 0.5:
			start_air_normal_forward_attack(1)
			pass

		else:
			start_air_neutral_normal_attack()
			pass
			
	elif can_chain and air_combo_step < 3:
		combo_queued = true

func handle_ground_special():
	if is_recovering:
		return
	
	if not is_ground_attacking:
		start_special_attack()
		

func start_neutral_attack():
	recovery_frames = 6
	is_ground_attacking = true
	
	player.velocity.x = 0
	
	animator.play_norm1()
	
	await animator.get_sprite().animation_finished
	
	reset_ground_combo(recovery_frames)

func start_neutral_normal_up_attack(horizontal):
	recovery_frames = 20
	is_air_attacking = true
	
	animator.play_norm_up()
	
	if player.velocity.x > 1:
		attack_slide_multiplier = 3.0 + (combo_step * 1.25)
		player.velocity.x = player.facing_direction * attack_slide_speed * attack_slide_multiplier 
	
	player.velocity.y = player.jump_velocity
	
	await animator.get_sprite().animation_finished
	
	await wait_for_frame(animator.get_sprite(), 20)
	reset_air_combo(recovery_frames)
	
func start_forward_attack(step):
	slide_frame = 4
	
	is_ground_attacking = true
	combo_step = step
	can_chain = false
	combo_queued = false
	
	player.velocity.x = 0
	
	match combo_step:
		1: animator.play_norm1()
		2: animator.play_norm2()
		3: animator.play_norm3()
		
	var sprite = animator.get_sprite()
	
	await wait_for_frame(sprite, slide_frame)

	attack_slide_multiplier = 3.0 + (combo_step * 1.25)
	player.velocity.x = player.facing_direction * attack_slide_speed * attack_slide_multiplier 
	
	await wait_for_frame(sprite, slide_frame + 2)
	player.velocity.x = 0

	open_combo_window(combo_window_frames)

	await animator.get_sprite().animation_finished

	if combo_queued and combo_step < 3:
		start_forward_attack(combo_step + 1)
	else:
		reset_ground_combo(recovery_frames)

func start_air_neutral_normal_attack():
	recovery_frames = 20
	is_air_attacking = true
	
	player.velocity.y = 0
	animator.play_norm1()
	var sprite = animator.get_sprite()
	sprite.frame = 3
	while sprite.frame < 4:
		await get_tree().process_frame
	
	#await animator.get_sprite().animation_finished
	
	reset_air_combo(recovery_frames)

func start_air_normal_forward_attack(step):
	recovery_frames = 25
	slide_frame = 3
	
	is_air_attacking = true
	air_combo_step = step
	can_chain = false
	combo_queued = false

	player.velocity.y = 0

	match air_combo_step:
		1: animator.play_norm1()
		2: animator.play_norm2()
		3: animator.play_norm3()

	var sprite = animator.get_sprite()
	
	await wait_for_frame(sprite, slide_frame)

	attack_slide_multiplier = 3.0 + (air_combo_step * 8)
	player.velocity.x = player.facing_direction * attack_slide_speed * attack_slide_multiplier 
	
	await wait_for_frame(sprite, slide_frame + 1)
	player.velocity.x = 0

	open_combo_window(combo_window_frames)

	await animator.get_sprite().animation_finished

	if combo_queued and air_combo_step < 3:
		start_air_normal_forward_attack(air_combo_step + 1)
	else:
		reset_air_combo(recovery_frames)

func start_air_normal_up_attack(horizontal):
	recovery_frames = 40
	is_air_attacking = true
	
	animator.play_norm_up()
	
	if player.velocity.x > 1:
		attack_slide_multiplier = 3.0 + (combo_step * 1.25)
		player.velocity.x = player.facing_direction * attack_slide_speed * attack_slide_multiplier 
	
	player.velocity.y = player.jump_velocity / 2
	
	#await animator.get_sprite().animation_finished
	
	#await wait_for_frame(animator.get_sprite(), 20)
	#player.velocity.y = 0
	reset_air_combo(recovery_frames)

func start_air_normal_down_attack(horizontal):
	recovery_frames = 35
	is_air_attacking = true
	
	animator.play_air_norm_down()
	
	if player.velocity.x > 1:
		attack_slide_multiplier = 3.0 + (combo_step * 1.25)
		player.velocity.x = player.facing_direction * attack_slide_speed * attack_slide_multiplier 
	
	#player.velocity.y = player.jump_velocity / 2
	#player.velocity.y = 0
	
	#await animator.get_sprite().animation_finished
	
	#await wait_for_frame(animator.get_sprite(), 20)

	reset_air_combo(recovery_frames)


func start_special_attack():
	slide_frame = 3
	recovery_frames = 20
	is_ground_attacking = true 
	
	animator.play_neutral_special()
	
	var sprite = animator.get_sprite()
	
	await wait_for_frame(sprite, slide_frame)

	player.velocity.x = (player.facing_direction * attack_slide_speed) * -1 
	
	await wait_for_frame(sprite, slide_frame + 1)
	player.velocity.x = 0
	
	await animator.get_sprite().animation_finished
	
	reset_ground_combo(recovery_frames)

func set_floor_state(on_floor: bool):
	if is_air_attacking and on_floor:
		reset_air_combo(recovery_frames)

func is_busy():
	return is_ground_attacking or is_air_attacking or is_recovering

func is_air_attacking_check():
	return is_air_attacking

func reset_ground_combo(recovery_frames):
	is_ground_attacking = false
	combo_step = 0
	await trigger_recovery(recovery_frames)
	reset_frame_data()

func reset_air_combo(recovery_frames):
	is_air_attacking = false
	air_combo_step = 0
	await trigger_recovery(recovery_frames)
	reset_frame_data()

func open_combo_window(combo_window_frames):
	can_chain = true

	for i in range(combo_window_frames):
		await get_tree().physics_frame

	can_chain = false

func trigger_recovery(recovery_frames):
	is_recovering = true

	for i in range(recovery_frames):
		await get_tree().physics_frame

	is_recovering = false
	
func reset_frame_data():
	slide_frame = DEFAULT_SLIDE_FRAME
	combo_window_frames = DEFAULT_COMBO_WINDOW
	recovery_frames = DEFAULT_RECOVERY	
	
func wait_for_frame(sprite: AnimatedSprite2D, target_frame: int) -> void:
	while sprite.frame < target_frame:
		await get_tree().physics_frame
