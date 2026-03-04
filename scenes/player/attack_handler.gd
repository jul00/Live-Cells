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

# Directional data


# Frame data, default given here, can be changed per attack in their respective functions
var slide_frame = 0
var combo_window_frames = 60
var recovery_frames = 10

# Stats
var attack_slide_speed = 50.0
var attack_slide_time = 0.15
var attack_slide_multiplier = 1

func _physics_process(delta):
	var horizontal: float = input_handler.get_move_direction()
	var vertical: float = Input.get_axis("up", "crouch")
	
	if input_handler.attack_pressed():
		handle_attack_input(horizontal, vertical)

func handle_attack_input(horizontal, vertical):
	if player.is_on_floor():
		handle_ground_attack(horizontal)

	else:
		handle_air_attack(horizontal, vertical)

func handle_ground_attack(horizontal):
	
	if is_recovering:
		return

	if not is_ground_attacking:
		if abs(horizontal) > 0.5:
			start_forward_attack(1)

		else:
			start_neutral_attack()
			
	elif can_chain and combo_step < 3:
		combo_queued = true
		
func handle_air_attack(horizontal, vertical):
	if is_recovering:
		return

	if not is_air_attacking:
		if vertical > 0.5:
			#start_air_down_attack()
			pass

		elif abs(horizontal) > 0.5:
			start_air_forward_attack(1)
			pass

		else:
			start_air_neutral_attack()
			pass
			
	elif can_chain and air_combo_step < 3:
		combo_queued = true

func start_neutral_attack():
	recovery_frames = 6
	is_ground_attacking = true
	
	animator.play_norm1()
	
	await animator.get_sprite().animation_finished
	
	reset_ground_combo(recovery_frames)
	
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

func start_air_neutral_attack():
	recovery_frames = 30
	is_air_attacking = true
	
	#player.velocity.x = 0
	animator.play_norm1()
	var sprite = animator.get_sprite()
	sprite.frame = 3
	while sprite.frame < 6:
		await get_tree().process_frame
	
	#await animator.get_sprite().animation_finished
	
	reset_air_combo(recovery_frames)

func start_air_forward_attack(step):
	slide_frame = 5
	
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
		start_air_forward_attack(air_combo_step + 1)
	else:
		reset_air_combo(recovery_frames)

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
	trigger_recovery(recovery_frames)

func reset_air_combo(recovery_frames):
	is_air_attacking = false
	air_combo_step = 0
	trigger_recovery(recovery_frames)

func open_combo_window(combo_window_frames):
	can_chain = true

	for i in combo_window_frames:
		await get_tree().physics_frame

	can_chain = false

func trigger_recovery(recovery_frames):

	is_recovering = true

	for i in recovery_frames:
		await get_tree().physics_frame

	is_recovering = false
	
func wait_for_frame(sprite: AnimatedSprite2D, target_frame: int) -> void:
	while sprite.frame < target_frame:
		await get_tree().physics_frame
