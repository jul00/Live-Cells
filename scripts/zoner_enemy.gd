extends CombatEntity

enum State { IDLE, ROAM, CHASE, FLEE, SPACING, ATTACK, HURT, DEATH, EVADE}

@export var speed: float = 80.0
@export var roam_speed: float = 30.0
@export var evade_speed: float = 250.0
@export var evade_duration: float = 0.5
@export var danger_zone_dist: float = 50.0 #112.5
@export var engagement_zone_dist: float = 168.0 # Increased by 40% (120 * 1.4)
@export var gravity_multiplier: float = 0.7
@export var stagger_recovery_time: float = 0.5

@onready var ray_cast = $RayCast2D
@onready var muzzle = $Muzzle
@onready var attack_timer = $AttackTimer

var current_state = State.IDLE
var state_timer: float = 0.0
var target_player: CharacterBody2D = null
var roam_target: Vector2 = Vector2.ZERO
var is_roaming = false
var roam_pause_timer = 0.0
var arrow_scene = preload("res://scenes/arrow.tscn")

var max_health_val: float = 280.0
var next_stagger_breaker_hp: float = 0.0

func _ready() -> void:
	health = 280.0
	max_health_val = health
	next_stagger_breaker_hp = max_health_val * (2.0/3.0)
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)

func _physics_process(delta: float) -> void:
	# 1. Global Gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# 2. State Logic
	if roam_pause_timer > 0:
		roam_pause_timer -= delta
		velocity.x = 0
	else:
		match current_state:
			State.IDLE:
				process_idle()
			State.ROAM:
				process_roam(delta)
			State.CHASE:
				process_chase(delta)
			State.FLEE:
				process_flee(delta)
			State.SPACING:
				process_spacing(delta)
			State.ATTACK:
				process_attack(delta)
			State.HURT:
				process_hurt(delta)
			State.EVADE:
				process_evade(delta)

	# 3. Global Ledge Detection (Safety Override)
	if is_on_floor() and abs(velocity.x) > 0:
		var is_moving_right = velocity.x > 0
		var ray_is_on_right = ray_cast.position.x > 0
		if (is_moving_right == ray_is_on_right) and not ray_cast.is_colliding():
			velocity.x = 0
			if current_state == State.ROAM:
				is_roaming = false
				var prev_dir = -1 if sprite.flip_h else 1
				pick_roam_point(-prev_dir)
				# Update facing immediately while paused
				roam_pause_timer = 0.5
			elif current_state in [State.FLEE, State.CHASE, State.SPACING, State.EVADE]:
				roam_pause_timer = 0.3
				if current_state == State.EVADE:
					change_state(State.IDLE)

	move_and_slide()
	update_animations()

func change_state(new_state: State) -> void:
	if current_state == new_state and new_state != State.HURT:
		return
	
	# Exit logic
	match current_state:
		State.ROAM:
			is_roaming = false
	
	current_state = new_state
	state_timer = 0.0
	
	# Entry logic
	match current_state:
		State.ATTACK:
			velocity.x = 0 # Stop moving when starting an attack
			# 33% chance to do a special attack
			if randf() <= 0.33:
				execute_attack("special-attack")
			else:
				execute_attack("attack")
		State.HURT:
			velocity.x = 0
			roam_pause_timer = 0.0 # Clear any ledge/roam pauses
			activate_hitbox("", false)
			sprite.stop()
			sprite.play("hurt")
		State.DEATH:
			velocity.x = 0
			activate_hitbox("", false)
			sprite.play("die")
		State.EVADE:
			if is_instance_valid(target_player):
				var dir_away = -1 if target_player.global_position.x > global_position.x else 1
				velocity.x = dir_away * evade_speed
				# Face the player while dashing away
				if velocity.x != 0:
					sprite.flip_h = velocity.x > 0
					update_combat_facing()
				sprite.play("dash")
			else:
				change_state(State.IDLE)


func process_idle() -> void:
	velocity.x = 0
	if target_player:
		evaluate_combat_state()
	else:
		change_state(State.ROAM)

func process_roam(_delta: float) -> void:
	if not is_roaming:
		pick_roam_point()
	
	var diff_x = roam_target.x - global_position.x
	var dir_x = 1 if diff_x > 0 else -1
	velocity.x = dir_x * roam_speed
	
	if abs(diff_x) < 10:
		is_roaming = false
		roam_pause_timer = 0.5
		pick_roam_point()
	
	if target_player:
		evaluate_combat_state()

func process_chase(_delta: float) -> void:
	if not target_player:
		change_state(State.ROAM)
		return
		
	var dir_to_player = (target_player.global_position - global_position).normalized()
	velocity.x = dir_to_player.x * roam_speed
	
	evaluate_combat_state()

func process_flee(_delta: float) -> void:
	if not target_player:
		change_state(State.ROAM)
		return
		
	var dir_to_player = (target_player.global_position - global_position).normalized()
	var flee_dir = -dir_to_player.x
	
	# Ledge check for fleeing (anti-boxing)
	var is_fleeing_right = flee_dir > 0
	var ray_is_on_right = ray_cast.position.x > 0
	if (is_fleeing_right == ray_is_on_right) and not ray_cast.is_colliding():
		velocity.x = 0 # Stop at ledge
	else:
		velocity.x = flee_dir * speed
	
	evaluate_combat_state()

func process_spacing(_delta: float) -> void:
	if not target_player:
		change_state(State.ROAM)
		return

	if attack_timer.is_stopped():
		change_state(State.ATTACK)
		return

	# While spacing and waiting for cooldown, back-pedal slowly
	var dir_to_player = (target_player.global_position - global_position).normalized()
	velocity.x = -dir_to_player.x * roam_speed
	evaluate_combat_state()

func process_attack(_delta: float) -> void:
	velocity.x = 0 # Ensure we stand still
	
	# If player vanishes suddenly
	if not target_player:
		change_state(State.ROAM)

func process_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer > stagger_recovery_time:
		change_state(State.IDLE)

func process_evade(delta: float) -> void:
	state_timer += delta
	if state_timer >= evade_duration:
		change_state(State.IDLE)

func evaluate_combat_state() -> void:
	if not target_player:
		change_state(State.ROAM)
		return
		
	var dist = global_position.distance_to(target_player.global_position)
	if dist < danger_zone_dist:
		change_state(State.FLEE)
	elif dist <= engagement_zone_dist:
		if attack_timer.is_stopped():
			change_state(State.ATTACK)
		else:
			change_state(State.SPACING)
	else:
		change_state(State.CHASE)

func execute_attack(anim_name: String) -> void:
	sprite.play(anim_name)
	attack_timer.start(2.5) # 2.5 second cooldown between attacks

func spawn_arrow(angle_offset: float) -> void:
	var arrow = arrow_scene.instantiate()
	get_tree().root.add_child(arrow)
	arrow.global_position = muzzle.global_position
	
	# Shoot horizontally in the direction the Archer is facing
	var face_dir = -1 if sprite.flip_h else 1
	var base_dir = Vector2(face_dir, 0)
	
	var rotated_dir = base_dir.rotated(deg_to_rad(angle_offset))
	arrow.rotation = rotated_dir.angle()

func _on_frame_changed() -> void:
	if current_state != State.ATTACK or not is_instance_valid(target_player):
		return
		
	if sprite.animation == "attack" and sprite.frame == 9:
		spawn_arrow(0)
	elif sprite.animation == "special-attack" and sprite.frame == 17:
		spawn_arrow(-15)
		spawn_arrow(0)
		spawn_arrow(15)

func _on_animation_finished() -> void:
	if current_state == State.ATTACK:
		# Clear the ATTACK state so the State Machine can cleanly re-enter it or another state
		current_state = State.IDLE
		if target_player:
			# Cooldown starts, evaluate where we should go
			evaluate_combat_state()
		else:
			change_state(State.ROAM)
	elif current_state == State.DEATH:
		handle_death(global_position)
		queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_player = body
		if current_state != State.ATTACK:
			evaluate_combat_state()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if target_player == body:
		target_player = null
		if current_state != State.ATTACK:
			change_state(State.ROAM)

func pick_roam_point(forced_dir: int = 0) -> void:
	var random_dir = forced_dir if forced_dir != 0 else (1 if randf() > 0.5 else -1)
	roam_target = Vector2(global_position.x + random_dir * randf_range(100, 200), global_position.y)
	is_roaming = true

func receive_hit(damage: float, attacker: Node2D) -> float:
	var final_damage = super.receive_hit(damage, attacker)
	
	if health <= 0:
		change_state(State.DEATH)
		return final_damage
		
	# Stagger Breaker Thresholds (2/3 and 1/3 HP)
	if health > 0 and health <= next_stagger_breaker_hp:
		if next_stagger_breaker_hp > max_health_val * 0.4:
			next_stagger_breaker_hp = max_health_val * (1.0/3.0) # Set for next threshold
		else:
			next_stagger_breaker_hp = -1.0 # Disable after final threshold
			
		print(name, " triggered Stagger Breaker (Evasive Dash)!")
		if is_instance_valid(attacker):
			var dist_x = attacker.global_position.x - global_position.x
			var dir_to_attacker = sign(dist_x)
			# Update facing to face the player before dashing away
			sprite.flip_h = dir_to_attacker < 0
			update_combat_facing()
		change_state(State.EVADE)
		return final_damage

	change_state(State.HURT)
	return final_damage

func update_facing() -> void:
	var face_dir = 0
	if velocity.x != 0:
		face_dir = 1 if velocity.x > 0 else -1
	elif target_player:
		face_dir = 1 if target_player.global_position.x > global_position.x else -1
	
	if face_dir == 0: return
	var is_left = face_dir < 0
	sprite.flip_h = is_left
	ray_cast.position.x = -15 if is_left else 15
	muzzle.position.x = -30 if is_left else 30
	update_combat_facing()

func update_animations() -> void:
	update_facing()
	
	if current_state in [State.ATTACK, State.HURT, State.DEATH, State.EVADE]:
		# Attack, hurt and death animations are handled separately
		return
		
	if abs(velocity.x) > 0:
		sprite.play("run")
	else:
		sprite.play("idle")
