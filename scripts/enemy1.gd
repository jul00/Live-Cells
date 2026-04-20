extends CharacterBody2D

# --- STATES ---
enum State {
	IDLE,
	ROAM,
	ATTACK
}

var current_state: State = State.IDLE

# --- SETTINGS ---
@export var speed: float = 120
@export var detection_range: float = 300
@export var roam_radius: float = 150
@export var attack_range: float = 60   # distance to trigger attack

# --- VARIABLES ---
var player: CharacterBody2D
var roam_target: Vector2
var idle_timer: float = 0.0

@onready var sprite = $AnimatedSprite2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	set_state(State.IDLE)

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	match current_state:
		State.IDLE:
			idle_state(delta)
		State.ROAM:
			roam_state(delta)
		State.ATTACK:
			attack_state(delta)

	move_and_slide()

# -------------------------
# IDLE
# -------------------------
func idle_state(delta):
	velocity.x = 0

	# play idle animation
	if sprite.animation != "idle":
		sprite.play("idle")

	idle_timer -= delta
	if idle_timer <= 0:
		set_state(State.ROAM)

	# detect player
	if player and position.distance_to(player.position) < detection_range:
		set_state(State.ATTACK)

# -------------------------
# ROAM
# -------------------------
func roam_state(delta):
	var direction_x = sign(roam_target.x - position.x)
	velocity.x = direction_x * speed

	# flip sprite
	sprite.flip_h = direction_x < 0

	# play run animation
	if sprite.animation != "run":
		sprite.play("run")

	# reached target
	if abs(roam_target.x - position.x) < 10:
		set_state(State.IDLE)

	# detect player
	if player and position.distance_to(player.position) < detection_range:
		set_state(State.ATTACK)

# -------------------------
# ATTACK
# -------------------------
func attack_state(delta):
	if not player:
		set_state(State.IDLE)
		return

	var distance = position.distance_to(player.position)
	var direction_x = sign(player.position.x - position.x)

	# flip sprite
	sprite.flip_h = direction_x < 0

	# if close enough → attack
	if distance < attack_range:
		velocity.x = 0

		if sprite.animation != "attack":
			sprite.play("attack")
	else:
		# chase player
		velocity.x = direction_x * speed * 1.5

		if sprite.animation != "run":
			sprite.play("run")

	# if player escapes
	if distance > detection_range:
		set_state(State.ROAM)

# -------------------------
# STATE SWITCH
# -------------------------
func set_state(new_state: State):
	current_state = new_state

	match current_state:
		State.IDLE:
			idle_timer = randf_range(1.0, 2.5)
			velocity.x = 0

		State.ROAM:
			roam_target = position + Vector2(
				randf_range(-roam_radius, roam_radius),
				0
			)

		State.ATTACK:
			pass
