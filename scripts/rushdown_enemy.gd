extends CombatEntity

enum State { IDLE, ROAM, APPROACH, PRE_ATTACK, COMBAT, DEFEND, HURT, DEATH }

@export_group("Movement")
@export var speed: float = 180.0 # Faster than Shoto
@export var roam_speed: float = 60.0
@export var gravity_multiplier: float = 1.0

const FACING_DEADZONE: float = 10.0

@export_group("Combat")
@export var detection_range: float = 250.0
@export var attack_range: float = 30.0 # Initiation range
@export var lunge_min_range: float = 50.0 # Only lunge if outside this
@export var lunge_max_range: float = 85.0 # Max effective lunge distance
@export var stagger_recovery_time: float = 0.2
@export var defend_chance: float = 0.6 # High chance to reactively block
@export var counter_delay: float = 0.1 # Delay after block before counter-attacking
@export var attack_cooldown_duration: float = 0.8 # Time to wait after a combo before re-approaching

@onready var ray_cast = $RayCast2D

var current_state = State.IDLE
var target_player: CharacterBody2D = null
var is_roaming = false
var roam_target = Vector2.ZERO
var state_timer = 0.0
var roam_pause_timer = 0.0
var attack_cooldown_timer = 0.0

var max_health_val: float = 192.0
var next_stagger_breaker_hp: float = 0.0

func _ready() -> void:
	super._ready()
	health = 192.0 # Reduced HP (320 * 0.6)
	max_health_val = health
	next_stagger_breaker_hp = max_health_val * (2.0/3.0)
	
	hitbox_profiles = {
		"atk1": {"pos": Vector2(25, -20), "size": Vector2(37, 40), "damage": 60.0}, # Lunge
		"atk2": {"pos": Vector2(20, -20), "size": Vector2(32, 40), "damage": 60.0}, # Fast follow-up
		"atk3": {"pos": Vector2(20, -15), "size": Vector2(50, 40), "damage": 60.0} # Heavy Counter
	}
	
	sprite.animation_finished.connect(_on_animation_finished)
	
	# Add to groups
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	# 1. Gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	# 2. Player Awareness
	if is_instance_valid(target_player):
		_evaluate_combat_logic(delta)
	else:
		target_player = null
		if current_state not in [State.IDLE, State.ROAM]:
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
		State.HURT:
			_process_hurt(delta)
		State.PRE_ATTACK:
			_process_pre_attack(delta)

	move_and_slide()
	_update_animations()

func change_state(new_state: State) -> void:
	if current_state == new_state and new_state != State.HURT:
		return
	
	# Exit logic
	match current_state:
		State.ROAM:
			is_roaming = false
		State.PRE_ATTACK:
			# Ensure the telegraph color is cleared if interrupted
			sprite.modulate = Color.WHITE
	
	current_state = new_state
	state_timer = 0.0
	
	# Entry logic
	match current_state:
		State.IDLE:
			velocity.x = 0
			if randf() < 0.4:
				perform_look_around()
		State.APPROACH:
			pass
		State.DEFEND:
			velocity.x = 0
			sprite.play("defend")
			sprite.stop()
			sprite.frame = 0
		State.HURT:
			velocity.x = 0
			activate_hitbox("", false)
			sprite.stop()
			sprite.play("hurt")
		State.COMBAT:
			velocity.x = 0
			_start_attack("atk1")
		State.DEATH:
			velocity.x = 0
			activate_hitbox("", false)
			sprite.play("die")
		State.PRE_ATTACK:
			velocity.x = 0
			sprite.play("idle")

func _evaluate_combat_logic(_delta: float) -> void:
	if current_state == State.DEATH:
		return

	if is_line_of_sight_blocked(target_player):
		if current_state != State.IDLE and current_state != State.ROAM:
			change_state(State.IDLE)
		return
		
	var dist = global_position.distance_to(target_player.global_position)
	
	# Reactive Blocking (Duelist trait)
	# Removed random block chance to focus on HP-threshold resets

	if current_state == State.IDLE or current_state == State.ROAM:
		if attack_cooldown_timer <= 0:
			change_state(State.APPROACH)
	elif current_state == State.APPROACH:
		if dist <= attack_range:
			change_state(State.PRE_ATTACK)
	elif current_state == State.COMBAT:
		# If player gets away during combo wind-up
		if dist > attack_range * 1.8 and sprite.animation not in ["atk1", "atk2"]:
			change_state(State.APPROACH)

func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer > 1.0:
		change_state(State.ROAM)

func _process_roam(delta: float) -> void:
	if roam_pause_timer > 0:
		roam_pause_timer -= delta
		velocity.x = 0
		return

	if not is_roaming:
		var dir = 1 if randf() > 0.5 else -1
		roam_target = global_position + Vector2(dir * randf_range(60, 120), 0)
		is_roaming = true
		_update_facing(dir)
	
	var move_dir = 1 if not sprite.flip_h else -1
	velocity.x = move_dir * roam_speed
	
	if (is_on_floor() and not ray_cast.is_colliding()) or is_on_wall() or abs(roam_target.x - global_position.x) < 5:
		velocity.x = 0
		is_roaming = false
		roam_pause_timer = 0.8
		change_state(State.IDLE)

func _process_approach(_delta: float) -> void:
	var dist_x = target_player.global_position.x - global_position.x
	var dir_x = sign(dist_x)
	
	# Deadzone to prevent jittering
	if abs(dist_x) > FACING_DEADZONE:
		_update_facing(dir_x)
		
	velocity.x = dir_x * speed
	
	# Standardized ledge safety
	if is_on_floor() and not ray_cast.is_colliding():
		velocity.x = 0
		change_state(State.IDLE)

func _process_combat(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 600 * delta)

func _process_pre_attack(delta: float) -> void:
	state_timer += delta
	if int(state_timer * 10) % 2 == 0:
		sprite.modulate = Color(15, 15, 0, 1)
	else:
		sprite.modulate = Color.WHITE
		
	if state_timer >= 0.5: # Faster telegraph for rushdown
		sprite.modulate = Color.WHITE
		change_state(State.COMBAT)

func _process_defend(delta: float) -> void:
	state_timer += delta
	# After some time or player stops attacking, counter-attack
	if state_timer > 0.6:
		_start_counter_attack()

func _process_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer >= stagger_recovery_time:
		change_state(State.IDLE)

func _start_attack(anim_name: String) -> void:
	sprite.play(anim_name)
	
	# Conditional Lunge for atk1
	if anim_name == "atk1":
		if is_instance_valid(target_player):
			var dist = global_position.distance_to(target_player.global_position)
			# Lunge only if in the 50-85 sweet spot
			if dist >= lunge_min_range and dist <= lunge_max_range:
				var lunge_dir = 1 if not sprite.flip_h else -1
				# Reduced speed multiplier to 2x
				velocity.x = lunge_dir * speed * 2
			else:
				# If already close (dist < 50), stay stationary to maintain precise pressure
				velocity.x = 0
		else:
			velocity.x = 0
	
	# Small delay for hitbox sync
	var delay = 0.2 if anim_name != "atk3" else 0.4
	get_tree().create_timer(delay).timeout.connect(func():
		if current_state == State.COMBAT and sprite.animation == anim_name:
			activate_hitbox(anim_name, true)
	)

func _start_counter_attack() -> void:
	change_state(State.COMBAT)
	_start_attack("atk3") # Heavy counter reserved for atk3

func _on_animation_finished() -> void:
	activate_hitbox("", false)
	match current_state:
		State.COMBAT:
			if sprite.animation == "atk1":
				_start_attack("atk2") # Combo chain
			else:
				attack_cooldown_timer = attack_cooldown_duration
				change_state(State.IDLE)
		State.DEFEND:
			# If the defend animation finishes naturally without being hit, counter
			_start_counter_attack()
		State.DEATH:
			handle_death(global_position)
			queue_free()

func _update_facing(dir_x: float) -> void:
	if dir_x == 0: return
	var wants_left = dir_x < 0
	if sprite.flip_h != wants_left:
		sprite.flip_h = wants_left
		# Rushdown native faces RIGHT. flip_h=true is LEFT.
		# If wants_left (true), ray should be on the left (-24).
		ray_cast.position.x = -24 if wants_left else 24
		update_combat_facing()

func _update_animations() -> void:
	if current_state in [State.COMBAT, State.DEFEND, State.HURT, State.DEATH]:
		return
		
	activate_hitbox("", false)
	
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
			sprite.play("defend") # Show impact
			var am = get_node_or_null("/root/AudioManager")
			if am:
				am.play_sfx("block")
			final_damage *= 0.1 # 90% reduction
			print(name, " blocked hit!")
			
			if is_instance_valid(attacker):
				var knockback_dir = (attacker.global_position - global_position).normalized()
				attacker.velocity += knockback_dir * 200.0
			
			# Retaliate after block (Rushdown trait)
			var d = super.receive_hit(final_damage, attacker)
			_start_counter_attack()
			return d
		else:
			_update_facing(dir_to_attacker)

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
		if current_state not in [State.PRE_ATTACK, State.COMBAT]:
			change_state(State.HURT)
		else:
			play_hit_flash()
		
	return final_damage

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if target_player == body:
		target_player = null

func play_hit_flash():
	if not sprite: return
	
	var tween = create_tween()
	sprite.modulate = Color(15, 15, 15, 1) 
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
