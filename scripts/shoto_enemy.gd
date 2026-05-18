extends CombatEntity

enum State { IDLE, ROAM, APPROACH, COMBAT, DEFEND, DASH_ATTACK, THROW, HURT, EVADE, DEATH}

@export_group("Movement")
@export var speed: float = 100.0
@export var roam_speed: float = 40.0
@export var gravity_multiplier: float = 1.0

@export_group("Combat")
@export var detection_range: float = 100.0
@export_range(0, 500) var attack_range: float = 30.0
@export var defend_range: float = 80.0
@export var dash_range: float = 180.0
@export var dash_speed: float = 250.0
@export var evade_speed: float = 300.0
@export var evade_duration: float = 0.4

@export_group("Zoning")
@export var buffer_range_min: float = 100.0
@export var buffer_range_max: float = 200.0
@export var shuriken_cooldown_time: float = 2.0
@export var stagger_recovery_time: float = 0.5

@onready var ray_cast = $RayCast2D

var current_state = State.IDLE
var target_player: CharacterBody2D = null
var is_roaming = false
var roam_target = Vector2.ZERO
var state_timer = 0.0
var combo_step = 0
var shuriken_timer = 0.0
var shuriken_scene = preload("res://scenes/shuriken.tscn")

var max_health_val: float = 360.0
var next_stagger_breaker_hp: float = 0.0

func _ready() -> void:
	super._ready()
	health = 360.0
	max_health_val = health
	next_stagger_breaker_hp = max_health_val * (2.0/3.0)
	hitbox_profiles = {
		"atk1": {"pos": Vector2(20, -25), "size": Vector2(38, 38), "damage": 40.0},
		"atk2": {"pos": Vector2(14, -21), "size": Vector2(30, 40), "damage": 40.0}, #x-y w-h
		"atk3": {"pos": Vector2(9, -15), "size": Vector2(48, 30), "damage": 40.0},
		"dash-atk": {"pos": Vector2(16, -14), "size": Vector2(48, 5), "damage": 40.0}
	}
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)

func _physics_process(delta: float) -> void:

	# 1. Handle Gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# 2. State Evaluation
	if is_instance_valid(target_player):
		_evaluate_combat_state()
	else:
		target_player = null
		if current_state != State.IDLE and current_state != State.ROAM:
			change_state(State.IDLE)

	# 3. State Processing
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.ROAM:
			_process_roam(delta)
		State.APPROACH:
			_process_approach(delta)
		State.COMBAT:
			_process_combat(delta)
		State.DEFEND:
			_process_defend(delta)
		State.DASH_ATTACK:
			_process_dash_attack(delta)
		State.THROW:
			_process_throw(delta)
		State.HURT:
			_process_hurt(delta)
		State.EVADE:
			_process_evade(delta)

	move_and_slide()
	_update_animations()

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
		State.IDLE:
			velocity.x = 0
			if randf() < 0.4:
				perform_look_around()
		State.COMBAT:
			velocity.x = 0
			combo_step = 0
			_start_attack("atk1")
		State.DASH_ATTACK:
			_start_dash_attack()
		State.DEFEND:
			velocity.x = 0
			sprite.play("defend")
			sprite.stop()
			sprite.frame = 0
		State.THROW:
			velocity.x = 0
			sprite.play("throw")
			shuriken_timer = shuriken_cooldown_time
		State.HURT:
			velocity.x = 0
			activate_hitbox("", false)
			sprite.stop()
			sprite.play("hurt")
		State.EVADE:
			if is_instance_valid(target_player):
				if AudioManager:
					AudioManager.play_sfx("dash")
				var dir_away = -1 if target_player.global_position.x > global_position.x else 1
				velocity.x = dir_away * evade_speed
				_update_facing(-dir_away) # Face the player while moving away
				sprite.play("run")
			else:
				change_state(State.IDLE)
		State.DEATH:
			velocity.x = 0
			activate_hitbox("", false)
			sprite.play("die")


func _evaluate_combat_state() -> void:
	var dist = global_position.distance_to(target_player.global_position)
	shuriken_timer -= get_physics_process_delta_time()
	
	if current_state == State.IDLE or current_state == State.ROAM:
		change_state(State.APPROACH)
	elif current_state == State.APPROACH:
		if dist <= attack_range:
			change_state(State.COMBAT)
		elif shuriken_timer <= 0 and dist >= buffer_range_min and dist <= buffer_range_max:
			var relative_vel_x = target_player.velocity.x
			var dist_x = target_player.global_position.x - global_position.x
			# If player is moving towards the enemy
			if abs(relative_vel_x) > 100 and sign(relative_vel_x) != sign(dist_x):
				change_state(State.THROW)
		elif dist <= dash_range and randf() < 0.01:
			change_state(State.DASH_ATTACK)
	elif current_state == State.COMBAT:
		if dist > attack_range * 1.5 and sprite.animation not in ["atk1", "atk2", "atk3"]:
			change_state(State.APPROACH)

func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer > 1.5:
		change_state(State.ROAM)

func _process_roam(_delta: float) -> void:
	if not is_roaming:
		var dir = 1 if randf() > 0.5 else -1
		roam_target = global_position + Vector2(dir * randf_range(60, 150), 0)
		is_roaming = true
		_update_facing(dir)

	var move_dir = 1 if sprite.flip_h else -1
	velocity.x = move_dir * speed

	if (is_on_floor() and not ray_cast.is_colliding()) or is_on_wall():
		velocity.x = 0
		is_roaming = false
		change_state(State.IDLE)
		return

	if abs(roam_target.x - global_position.x) < 10:
		velocity.x = 0
		is_roaming = false
		change_state(State.IDLE)

func _process_approach(_delta: float) -> void:

	if not is_instance_valid(target_player):
		change_state(State.IDLE)
		return
		
	var dist_x = target_player.global_position.x - global_position.x
	var dir_x = 1 if dist_x > 0 else -1
	
	_update_facing(dir_x)
	velocity.x = dir_x * speed
	
	if is_on_floor() and not ray_cast.is_colliding():
		velocity.x = 0
		change_state(State.IDLE)

func _process_combat(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 800 * delta)
	if not is_instance_valid(target_player):
		change_state(State.IDLE)
		return
		
	var dir_x = 1 if target_player.global_position.x > global_position.x else -1
	_update_facing(dir_x)

func _process_defend(delta: float) -> void:
	state_timer += delta
	if state_timer > 1.0:
		change_state(State.APPROACH)

func _process_throw(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)

func _process_dash_attack(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)

func _process_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer >= stagger_recovery_time:
		if randf() < 0.33:
			change_state(State.EVADE)
		else:
			change_state(State.IDLE)

func _process_evade(delta: float) -> void:
	state_timer += delta
	if state_timer >= evade_duration:
		change_state(State.IDLE)
	
	# Slow down slightly over time or keep constant? Let's keep it constant for the dash duration
	if is_on_wall() or (is_on_floor() and not ray_cast.is_colliding()):
		velocity.x = 0
		change_state(State.IDLE)

func _start_attack(anim_name: String):
	sprite.play(anim_name)
	
	if anim_name == "atk3":
		# Wait for 0.4s (syncing with animation frames) before enabling the hitbox
		get_tree().create_timer(0.4).timeout.connect(func():
			if current_state == State.COMBAT and sprite.animation == "atk3":
				activate_hitbox(anim_name, true)
		)
	else:
		activate_hitbox(anim_name, true)
		
	if is_instance_valid(target_player):
		var dir_x = 1 if target_player.global_position.x > global_position.x else -1
		_update_facing(dir_x)

func _start_dash_attack():
	sprite.play("dash-atk")
	
	# Wait for 0.4s (syncing with dash lunge) before enabling the hitbox
	get_tree().create_timer(0.6).timeout.connect(func():
		if current_state == State.DASH_ATTACK and sprite.animation == "dash-atk":
			activate_hitbox("dash-atk", true)
	)
	
	var dir_x = -1 if sprite.flip_h else 1
	velocity.x = dir_x * dash_speed

func _on_animation_finished():
	activate_hitbox("", false)
	match current_state:
		State.COMBAT:
			if sprite.animation == "atk1":
				combo_step = 1
				_start_attack("atk2")
			elif sprite.animation == "atk2":
				combo_step = 2
				_start_attack("atk3")
			else:
				combo_step = 0
				change_state(State.IDLE)
		State.DASH_ATTACK:
			change_state(State.COMBAT)
		State.DEFEND:
			change_state(State.APPROACH)
		State.THROW:
			change_state(State.APPROACH)
		State.HURT:
			pass # Recovery handled in _physics_process
		State.DEATH:
			handle_death(global_position)
			queue_free()

func _on_frame_changed():
	if current_state == State.THROW and sprite.animation == "throw" and sprite.frame == 3:
		_spawn_shuriken()

func _spawn_shuriken():
	var shuriken = shuriken_scene.instantiate()
	get_tree().root.add_child(shuriken)
	shuriken.global_position = global_position + Vector2(0, -16)

	if sprite.flip_h:
		shuriken.rotation = PI
	else:
		shuriken.rotation = 0

func _on_detection_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		target_player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if target_player == body:
		target_player = null

func _update_facing(dir_x: float) -> void:
	if dir_x == 0: return
	sprite.flip_h = dir_x < 0
	ray_cast.position.x = 15 if dir_x > 0 else -15
	update_combat_facing()

func _update_animations() -> void:
	if current_state in [State.COMBAT, State.DASH_ATTACK, State.DEFEND, State.THROW, State.HURT, State.EVADE, State.DEATH]:
		return
	
	activate_hitbox("", false) # Safety cleanup
		
	if abs(velocity.x) > 10:
		sprite.play("run")
	else:
		sprite.play("idle")

func receive_hit(damage: float, attacker: Node2D) -> float:
	var final_damage = damage
	var was_blocked = false
	
	if current_state == State.DEFEND:
		var dir_to_attacker = sign(attacker.global_position.x - global_position.x)
		var is_facing_right = not sprite.flip_h
		var hit_from_front = (is_facing_right and dir_to_attacker > 0) or (not is_facing_right and dir_to_attacker < 0)
		
		if hit_from_front:
			was_blocked = true
			sprite.stop()
			sprite.play("defend") # Show the block on hit
			if AudioManager:
				AudioManager.play_sfx("block")
			final_damage *= 0.1 # 90% reduction
			print(name, " blocked hit!")
			
			if is_instance_valid(attacker):
				var knockback_dir = (attacker.global_position - global_position).normalized()
				attacker.velocity += knockback_dir * 200.0
		else:
			_update_facing(dir_to_attacker) # Turn to face attacker if hit from behind

	super.receive_hit(final_damage, attacker)
	
	if health <= 0:
		change_state(State.DEATH)
		return final_damage
		
	# Stagger Breaker Thresholds (2/3 and 1/3 HP)
	if health > 0 and health <= next_stagger_breaker_hp:
		if next_stagger_breaker_hp > max_health_val * 0.4:
			next_stagger_breaker_hp = max_health_val * (1.0/3.0) # Set for next threshold
		else:
			next_stagger_breaker_hp = -1.0 # Disable after final threshold
			
		print(name, " triggered Stagger Breaker!")
		if is_instance_valid(attacker):
			var dir_to_attacker = sign(attacker.global_position.x - global_position.x)
			_update_facing(dir_to_attacker)
		change_state(State.DEFEND)
		return final_damage

	if not was_blocked:
		change_state(State.HURT)
		
	return final_damage
