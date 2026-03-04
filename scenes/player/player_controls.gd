extends CharacterBody2D

@onready var animator = $PlayerAnimator
@onready var input_handler: Node = $PlayerInput
@onready var attack_handler: Node = $AttackHandler


var movespeed = 300.0
var jump_velocity = -500.0
var facing_direction = 1

func _physics_process(delta):

	# Pass floor state to attack handler
	attack_handler.set_floor_state(is_on_floor())

	# Apply gravity only if attack handler allows
	if not is_on_floor() and not attack_handler.is_air_attacking_check():
		velocity += get_gravity() * delta

	# If attacking, stop movement
	if attack_handler.is_busy():
		move_and_slide()
		return

	# Movement
	var direction : float = input_handler.get_move_direction()

	if is_on_floor():
		if direction:
			velocity.x = direction * movespeed
			animator.play_run()
			facing_direction = direction
			animator.set_facing(direction)
		else:
			velocity.x = move_toward(velocity.x, 0, movespeed)
			animator.play_idle()

	# Jump
	if input_handler.jump_pressed() and is_on_floor():
		velocity.y = jump_velocity
		animator.play_jump()

	move_and_slide()
