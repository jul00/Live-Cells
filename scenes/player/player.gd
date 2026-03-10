extends CharacterBody2D

signal landed

@onready var animator = $PlayerAnimator
@onready var input_handler: Node = $PlayerInput
@onready var attack_handler: Node = $AttackHandler

# Physics stats
var movespeed = 400.0
var jump_velocity = -500.0
var facing_direction = 1
var ground_friction = 2000.0 # lower value = longer slide

# Dash stats
var dash_speed = 400
var dash_time = 0.25
var dash_cooldown = 0.40
var is_dashing = false

# Dash double tap detection
var double_tap_time = 0.2
var last_left_press = -1.0
var last_right_press = -1.0

func _physics_process(delta):
	# Pass floor state to attack handler
	attack_handler.set_floor_state(is_on_floor())
	print("y velocity: ", velocity.y)
	print("x velocity: ", velocity.x)
	
	# If dashing, prevent movement
	if is_dashing:
		move_and_slide()
		return
	
	# If attacking, prevent movement
	if attack_handler.is_busy():
		# Only apply gravity if the attack allows air movement
		if not is_on_floor() and not attack_handler.is_air_attacking_check():
			velocity += get_gravity() * delta
		move_and_slide()
		return
		
	# Apply gravity only if attack handler allows
	if not is_on_floor() and not attack_handler.is_air_attacking_check():
		print("not on floor")
		velocity += get_gravity() * delta
		if velocity.y > 0:
			animator.play_fall() 
		else:
			animator.play_jump() 
	
	# Dash
	var time = Time.get_ticks_msec() / 1000.0

	if Input.is_action_just_pressed("move_left"):
		if time - last_left_press < double_tap_time:
			start_dash(-1)
			return
		last_left_press = time

	if Input.is_action_just_pressed("move_right"):
		if time - last_right_press < double_tap_time:
			start_dash(1)
			return
		last_right_press = time
		
	if Input.is_action_just_pressed("dash"):
		start_dash(facing_direction)
		return
	
	# Movement
	var direction : float = input_handler.get_move_direction()

	if is_on_floor():
		print("on floor")
		if direction:
			velocity.x = direction * movespeed
			animator.play_run()
			facing_direction = direction
			animator.set_facing(direction)
		else:
			velocity.x = move_toward(velocity.x, 0, ground_friction * delta) # momentum slide
			animator.play_idle()

	# Jump
	if input_handler.jump_pressed() and is_on_floor():
		velocity.y = jump_velocity
		animator.play_jump()
	#Short hop
	if input_handler.jump_released() and velocity.y < 0:
		velocity.y = jump_velocity / 20

	move_and_slide()
	
func start_dash(direction):
	if is_dashing:
		return
	
	is_dashing = true
	
	facing_direction = direction
	animator.set_facing(direction)

	velocity.y = 0
	velocity.x = direction * dash_speed

	animator.play_dash()
	
	#await animator.get_sprite().animation_finished

	await get_tree().create_timer(dash_time).timeout

	is_dashing = false

	await get_tree().create_timer(dash_cooldown).timeout
