extends CharacterBody2D

const SPEED = 300.0
const RUN_SPEED = 500.0
const JUMP_VELOCITY = -600.0
const NOCLIP_SPEED = 600.0

var noclip := false

@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox = $CollisionShape2D

func _ready():
	add_to_group("player")

func _physics_process(delta: float) -> void:

	var direction := Input.get_axis("a", "d")
	var current_speed = SPEED

	# Toggle noclip
	if Input.is_action_just_pressed("c"):
		noclip = !noclip
		hitbox.disabled = noclip

	if noclip:
		animated_sprite.play("idle")
		
		if direction != 0:
			velocity.x = direction * current_speed
			animated_sprite.flip_h = direction < 0

		var x_dir = Input.get_axis("a", "d")
		var y_dir = Input.get_axis("w", "s")

		velocity.x = x_dir * NOCLIP_SPEED
		velocity.y = y_dir * NOCLIP_SPEED

		move_and_slide()
		return


	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("shift"):
		current_speed = RUN_SPEED

	# Horizontal movement
	if direction != 0:
		velocity.x = direction * current_speed
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animation
	if not is_on_floor():
		if velocity.y < 0:
			if animated_sprite.animation != "jump":
				animated_sprite.play("jump")
		else:
			if animated_sprite.animation != "fall":
				animated_sprite.play("fall")
	else:
		if direction == 0:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		else:
			if current_speed == RUN_SPEED:
				if animated_sprite.animation != "run":
					animated_sprite.play("run")
			else:
				if animated_sprite.animation != "walk":
					animated_sprite.play("walk")

	move_and_slide()
