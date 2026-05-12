extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -320.0
const COMBO_GRACE_TIME = 0.7
const WALL_SLIDE_SPEED = 100.0
const WALL_JUMP_PUSH = 200.0

@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.3
@export var gravity_multiplier: float = 0.7

enum State { MOVE, JUMP, ATTACK, DASH, DEFEND, HURT, DEATH, WALL }
var current_state = State.MOVE

@onready var sprite = $AnimatedSprite2D

var combo_step = -1
var next_attack_queued = false
var combo_grace_timer = 0.0
var attack_animations = ["atk1", "atk2", "atk3"]
var can_dash = true

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if current_state == State.DEATH:
		return

	if is_on_floor() or is_on_wall():
		can_dash = true

	# Update combo grace timer
	if combo_grace_timer > 0:
		combo_grace_timer -= delta

	# Wall detection
	if not is_on_floor() and is_on_wall() and current_state != State.ATTACK and velocity.y >= 0:
		if current_state != State.WALL:
			sprite.flip_h = get_wall_normal().x < 0
		change_state(State.WALL)

	# Add the gravity.
	if not is_on_floor():
		if current_state == State.MOVE:
			change_state(State.JUMP)
		
		var applied_gravity = get_gravity() * gravity_multiplier
		
		if current_state == State.WALL:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, applied_gravity.y * delta)
		elif current_state != State.DASH:
			velocity += applied_gravity * delta
	elif current_state == State.JUMP: 
		change_state(State.MOVE) # Return to MOVE state upon landing

	if current_state == State.WALL:
		if is_on_floor():
			change_state(State.MOVE)
		elif not is_on_wall():
			change_state(State.JUMP)

	if current_state == State.MOVE or current_state == State.JUMP or current_state == State.WALL:
		handle_movement_input(delta)
	
	handle_combat_input()
	
	move_and_slide()
	update_animations()

func change_state(new_state: State, anim_name: String = ""):
	if new_state == current_state and anim_name == "":
		return

	if current_state == State.ATTACK and new_state != State.ATTACK:
		next_attack_queued = false
	
	current_state = new_state
	if new_state == State.ATTACK or new_state == State.DEFEND:
		velocity.x = 0
	if anim_name != "":
		sprite.play(anim_name)
		return
	
	match current_state:
		State.MOVE:
			pass # Handled in _physics_process
		State.JUMP:
			sprite.play("jump-start")
		State.ATTACK:
			pass # Handled by combo logic
		State.DASH:
			sprite.play("dash")
		State.DEFEND:
			sprite.play("defend")
			sprite.stop()
			sprite.frame = 0
		State.HURT:
			sprite.play("hurt")
		State.DEATH:
			sprite.play("death")
		State.WALL:
			sprite.play("wall-contact")

func receive_hit(damage: float):
	if current_state == State.DEFEND:
		# Block the hit: play the animation and reduce damage
		sprite.play("defend")
		print("Blocked! Damage reduced.")
		# For now, we just reduce damage by 80%
		return damage * 0.2
	else:
		# Take full damage and enter HURT state
		change_state(State.HURT)
		return damage

func handle_movement_input(delta: float):
	if Input.is_action_just_pressed("Jump"):
		if current_state == State.WALL:
			var wall_normal = get_wall_normal()
			velocity = Vector2(wall_normal.x * WALL_JUMP_PUSH, JUMP_VELOCITY)
			sprite.flip_h = wall_normal.x > 0
			change_state(State.JUMP, "wall-jump")
			return
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY
			change_state(State.JUMP)

	var direction := Input.get_axis("A", "D")
	if direction:
		if current_state != State.WALL:
			sprite.flip_h = direction < 0
		
		if is_on_floor():
			velocity.x = direction * SPEED
		else:
			# Air acceleration to preserve jump momentum
			velocity.x = move_toward(velocity.x, direction * SPEED, 1500.0 * delta)
	else:
		var friction = SPEED if is_on_floor() else 800.0 * delta
		velocity.x = move_toward(velocity.x, 0, friction)

func attack():
	if current_state == State.JUMP:
		change_state(State.ATTACK, "air-atk")
		return

	# If we are not currently attacking, check if the grace timer is still active
	if current_state != State.ATTACK:
		if combo_grace_timer <= 0:
			combo_step = -1
		next_attack_queued = false
	
	combo_step = (combo_step + 1) % attack_animations.size()
	combo_grace_timer = COMBO_GRACE_TIME
	change_state(State.ATTACK, attack_animations[combo_step])

func handle_combat_input():
	if Input.is_action_just_pressed("attack"):
		if current_state == State.ATTACK:
			next_attack_queued = true
		else:
			attack()
	
	if Input.is_action_just_pressed("special-attack"):
		change_state(State.ATTACK, "special-atk")
		next_attack_queued = false
		combo_step = -1

	if Input.is_action_just_pressed("dash") and can_dash:
		change_state(State.DASH)
		var dash_dir = -1 if sprite.flip_h else 1
		velocity.x = dash_dir * dash_speed
		velocity.y = 0
		
		if not is_on_floor():
			can_dash = false
		
		# Create a one-shot timer for the dash duration
		get_tree().create_timer(dash_duration).timeout.connect(func():
			if current_state == State.DASH:
				velocity.x = 0
				change_state(State.MOVE)
		)

	if Input.is_action_pressed("defend"):
		change_state(State.DEFEND)
	elif current_state == State.DEFEND:
		change_state(State.MOVE)

func _on_animation_finished():
	if current_state == State.ATTACK:
		if next_attack_queued:
			next_attack_queued = false
			combo_step = (combo_step + 1) % attack_animations.size()
			change_state(State.ATTACK, attack_animations[combo_step])
		else:
			change_state(State.MOVE)
	elif current_state == State.DASH:
		velocity.x = 0
		change_state(State.MOVE)
	elif current_state == State.HURT:
		change_state(State.MOVE)
	if current_state == State.WALL and sprite.animation == "wall-contact":
		sprite.play("wall-slide")

func update_animations():
	match current_state:
		State.MOVE:
			if velocity.x == 0:
				sprite.play("idle")
			else:
				sprite.play("walk")
		State.JUMP:
			if velocity.y < 0:
				# Check if we just started or are transitioning
				if sprite.animation != "jump-start":
					sprite.play("jump-start")
			elif abs(velocity.y) < 50:
				sprite.play("jump-transition")
			else:
				sprite.play("jump-fall")
