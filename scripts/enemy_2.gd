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
@export var attack_range: float = 60

# IMPORTANT: fake "body size compensation"
@export var enemy_radius: float = 20
@export var player_radius: float = 10

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
# HELPER: TRUE DISTANCE
# -------------------------
func get_player_distance() -> float:
	if not player:
		return INF

	var raw_distance = global_position.distance_to(player.global_position)
	return raw_distance - (enemy_radius + player_radius)


# -------------------------
# IDLE
# -------------------------
func idle_state(delta):
	velocity.x = 0

	if sprite.animation != "idle":
		sprite.play("idle")

	idle_timer -= delta
	if idle_timer <= 0:
		set_state(State.ROAM)

	# detect player
	if player and get_player_distance() < detection_range:
		set_state(State.ATTACK)


# -------------------------
# ROAM
# -------------------------
func roam_state(delta):
	var direction_x = sign(roam_target.x - global_position.x)
	velocity.x = direction_x * speed

	sprite.flip_h = direction_x < 0

	if sprite.animation != "run":
		sprite.play("run")

	# reached target
	if abs(roam_target.x - global_position.x) < 10:
		set_state(State.IDLE)

	# detect player
	if player and get_player_distance() < detection_range:
		set_state(State.ATTACK)


# -------------------------
# ATTACK
# -------------------------
func attack_state(delta):
	if not player:
		set_state(State.IDLE)
		return

	var distance = get_player_distance()
	var direction_x = sign(player.global_position.x - global_position.x)

	sprite.flip_h = direction_x < 0

	if distance < attack_range:
		velocity.x = 0

		if sprite.animation != "attack":
			sprite.play("attack")
	else:
		velocity.x = direction_x * speed * 1.5

		if sprite.animation != "run":
			sprite.play("run")

	# lose player
	if distance > detection_range:
		set_state(State.ROAM)


# -------------------------
# STATE SWITCH
# -------------------------
func set_state(new_state: State):
	if current_state == new_state:
		return

	current_state = new_state

	match current_state:
		State.IDLE:
			idle_timer = randf_range(1.0, 2.5)
			velocity.x = 0

		State.ROAM:
			roam_target = global_position + Vector2(
				randf_range(-roam_radius, roam_radius),
				0
			)

		State.ATTACK:
			pass
