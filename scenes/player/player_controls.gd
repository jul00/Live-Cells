extends CharacterBody2D

@onready var player_animator = $PlayerAnimator

# Stats
var movespeed = 300.0
var jump_velocity = -500.0
var attack_slide_speed = 50.0
var attack_slide_time = 0.2
var slide_multiplier = 1.0

# State Management
var is_ground_attacking = false
var is_air_attacking = false
var can_chain = false
var combo_queued = false
var is_recovering = false

var combo_step = 0
var air_combo_step = 0

var combo_window = 0.35
var recovery_time = 0.35

var facing_direction = 1


func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("normal-attack"):
		handle_attack_input()
	
	if not is_on_floor() and not is_air_attacking:
		velocity += get_gravity() * delta
		if velocity.y > 0:
			player_animator.play_fall() # Trigger the falling animation
		else:
			player_animator.play_jump() 
			
	# Stops air combo once player touches the ground
	if is_air_attacking and is_on_floor():
		reset_air_combo()
		player_animator.play_idle()
	
	# Stop movement while attacking (but NOT input)
	if is_ground_attacking or is_air_attacking:
		move_and_slide()
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if is_on_floor():
		if direction:
			velocity.x = direction * movespeed
			player_animator.play_run()
			
			# Flip character ONLY on ground
			facing_direction = direction
			player_animator.set_facing(direction)
		else:
			velocity.x = move_toward(velocity.x, 0, movespeed)
			player_animator.play_idle()
	else:
		pass
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		player_animator.play_jump()
	# Short hop
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = jump_velocity / 4
	
	move_and_slide()

func start_attack(step):
	print("Ground attack")
	is_ground_attacking = true
	can_chain = false
	combo_queued = false
	combo_step = step
	
	
	slide_multiplier += ((combo_step - 1) * 0.5) 
	slide_multiplier = max(slide_multiplier, 0.1)
	# Slide
	velocity.x = facing_direction * attack_slide_speed * slide_multiplier
	
	match combo_step:
		1:
			player_animator.play_norm1()
		2:
			player_animator.play_norm2()
		3:
			player_animator.play_norm3()

	# Stop slide after short time
	await get_tree().create_timer(attack_slide_time).timeout
	velocity.x = 0

	# Open combo window WITHOUT blocking animation
	open_combo_window()

	# Wait ONLY for animation to finish
	await player_animator.get_sprite().animation_finished

	if combo_queued and combo_step < 3:
		start_attack(combo_step + 1)
	else:
		reset_combo()
		
func start_air_attack(step):
	print("Air attack")
	is_air_attacking = true
	can_chain = false
	combo_queued = false
	air_combo_step = step
	
	slide_multiplier += ((air_combo_step - 1) * 0.2) 
	slide_multiplier = max(slide_multiplier, 0.1)
	
	velocity.x = facing_direction * attack_slide_speed * slide_multiplier
	velocity.y = 0
	
	match air_combo_step:
		1:
			player_animator.play_norm1()
		2:
			player_animator.play_norm2()
		3:
			player_animator.play_norm3()


	open_combo_window()

	await player_animator.get_sprite().animation_finished

	if combo_queued and air_combo_step < 3:
		start_air_attack(air_combo_step + 1)
	else:
		reset_air_combo()

func handle_attack_input():
	
	if is_on_floor():
		handle_ground_attack()
	else:
		handle_air_attack()

func handle_ground_attack():
	if is_recovering:
		return
	
	if not is_ground_attacking:
		start_attack(1)
	elif can_chain and combo_step < 3:
		combo_queued = true

func handle_air_attack():
	if is_recovering:
		return
	
	if not is_air_attacking:
		start_air_attack(1)
	elif can_chain and air_combo_step < 3:
		combo_queued = true

func open_combo_window():
	can_chain = true
	
	await get_tree().create_timer(combo_window).timeout
	
	can_chain = false

func reset_combo():
	is_ground_attacking = false
	can_chain = false
	combo_queued = false
	combo_step = 0
	
	trigger_recovery()

func reset_air_combo():
	is_air_attacking = false
	can_chain = false
	combo_queued = false
	air_combo_step = 0
	
	trigger_recovery()

func trigger_recovery():
	is_recovering = true
	await get_tree().create_timer(recovery_time).timeout
	is_recovering = false
