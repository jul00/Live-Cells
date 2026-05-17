extends CombatEntity

enum State { IDLE, ROAM, APPROACH, COMBAT, DEFEND, SHOUT, HURT, DEATH, PRE_ATTACK }

@export_group("Movement")
@export var speed: float = 120.0
@export var roam_speed: float = 50.0
@export var gravity_multiplier: float = 1.0
@export var phase_2_speed_mult: float = 1.5

@export var attack_range: float = 50.0
@export var defend_range: float = 100.0
@export var health_threshold_phase_2: float = 0.5 # 50% health

@onready var ray_cast = $RayCast2D

var current_state = State.IDLE
var target_player: CharacterBody2D = null
var is_roaming = false
var roam_target = Vector2.ZERO
var state_timer = 0.0
var decision_timer = 0.0
var is_phase_2 = false
var max_health: float = 1500.0
var shout_triggered = false
var next_shout_hp: float = 0.0
var next_phase1_block_hp: float = 0.0

func _ready() -> void:
	health = 1500.0
	super._ready()
	max_health = health
	next_phase1_block_hp = max_health * 0.875 # First 25% of Phase 1 (1500 - 187.5 = 1312.5)
	# Default Boss Hitbox Profiles
	hitbox_profiles = {
		"atk1": {"pos": Vector2(20, -20), "size": Vector2(50, 30), "damage": 80.0},
		"atk2": {"pos": Vector2(20, -20), "size": Vector2(60, 48), "damage": 80.0},
		"atk3": {"pos": Vector2(30, -20), "size": Vector2(30, 60), "damage": 80.0},
		"shout": {"pos": Vector2(0, -20), "size": Vector2(150, 150), "damage": 0.0} # Push back AOE
	}
	sprite.animation_finished.connect(_on_animation_finished)
	# Check groups
	if not is_in_group("enemy"):
		add_to_group("enemy")

func _physics_process(delta: float) -> void:
	decision_timer -= delta
	# Handle Gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# State Evaluation
	if is_instance_valid(target_player):
		_evaluate_boss_logic()
	else:
		target_player = null
		if current_state not in [State.IDLE, State.ROAM, State.HURT, State.DEATH, State.SHOUT]:
			change_state(State.IDLE)

	# State Processing
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
		State.SHOUT:
			_process_shout(delta)
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
	
	current_state = new_state
	state_timer = 0.0
	
	# Entry logic
	match current_state:
		State.IDLE:
			velocity.x = 0
		State.COMBAT:
			velocity.x = 0
			_start_attack("atk1")
		State.DEFEND:
			velocity.x = 0
			sprite.play(get_anim("defend"))
			sprite.stop()
			sprite.frame = 0
		State.SHOUT:
			velocity.x = 0
			shout_triggered = true
			var anim = get_anim("shout")
			sprite.play(anim)
			
			# Calculate 4/5 duration of the animation
			var frames = sprite.sprite_frames.get_frame_count(anim)
			var fps = sprite.sprite_frames.get_animation_speed(anim)
			var duration = float(frames) / fps
			
			get_tree().create_timer(duration * 0.6).timeout.connect(func():
				if current_state == State.SHOUT:
					_perform_shout_knockback()
			)
		State.HURT:
			velocity.x = 0
			activate_hitbox("", false)
			sprite.play(get_anim("hurt"))
		State.DEATH:
			velocity.x = 0
			activate_hitbox("", false)
			sprite.play(get_anim("die"))
		State.PRE_ATTACK:
			velocity.x = 0
			sprite.play(get_anim("idle"))

func _process_pre_attack(delta: float) -> void:
	state_timer += delta
	
	# Full Yellow Blinking (every 0.1s)
	if int(state_timer * 10) % 2 == 0:
		sprite.modulate = Color(15, 15, 0, 1) # Full Yellow wash
	else:
		sprite.modulate = Color.WHITE
		
	if state_timer >= 0.8:
		sprite.modulate = Color.WHITE # Reset color
		change_state(State.COMBAT)

func _evaluate_boss_logic() -> void:
	if not is_instance_valid(target_player):
		return
		
	if current_state in [State.HURT, State.SHOUT, State.DEATH]:
		return

	var dist = global_position.distance_to(target_player.global_position)
	
	if current_state in [State.IDLE, State.ROAM]:
		# Boss must wait 1.0s in IDLE after a combo before approaching again
		if state_timer >= 1.0:
			change_state(State.APPROACH)
	elif current_state == State.APPROACH:
		if dist <= defend_range and decision_timer <= 0:
			var can_attack = dist <= attack_range or is_phase_2
			var roll = randf()

			if roll < 0.125: # 1/8 Chance to Defend
				change_state(State.DEFEND)
				decision_timer = 0.5
			elif can_attack: # 7/8 Chance to Attack if in range
				change_state(State.PRE_ATTACK) # NEW: Go through telegraph first
				decision_timer = 0.5
			else:
				# Keep approaching, check again in 0.2s
				decision_timer = 0.2

	elif current_state == State.COMBAT:
		var current_anim = sprite.animation
		var is_attacking = current_anim in [get_anim("atk1"), get_anim("atk2"), get_anim("atk3")]
		if dist > attack_range * 1.5 and not is_attacking:
			change_state(State.APPROACH)

func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer > 2.0:
		change_state(State.ROAM)

func _process_roam(delta: float) -> void:
	if not is_roaming:
		var dir = 1 if randf() > 0.5 else -1
		roam_target = global_position + Vector2(dir * randf_range(100, 200), 0)
		is_roaming = true
		_update_facing(dir)
	
	var move_dir = -1 if sprite.flip_h else 1
	velocity.x = move_dir * roam_speed
	
	if (is_on_floor() and not ray_cast.is_colliding()) or is_on_wall():
		velocity.x = 0
		is_roaming = false
		change_state(State.IDLE)
		return
		
	if abs(roam_target.x - global_position.x) < 15:
		velocity.x = 0
		is_roaming = false
		change_state(State.IDLE)

func _process_approach(delta: float) -> void:
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
	if is_instance_valid(target_player):
		var dir_x = 1 if target_player.global_position.x > global_position.x else -1

func _process_defend(delta: float) -> void:
	state_timer += delta
	if state_timer > 2.0:
		change_state(State.APPROACH)

func _process_shout(delta: float) -> void:
	# Shout is mostly handled by animation completion
	velocity.x = 0

func _process_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer >= 0.6:
		change_state(State.APPROACH if is_instance_valid(target_player) else State.IDLE)

func _start_attack(anim_name: String):
	sprite.play(get_anim(anim_name))
	
	activate_hitbox(anim_name, true)
	if is_phase_2 and anim_name in ["atk1", "atk2", "atk3"]:
		var lunge_dir = -1 if sprite.flip_h else 1
		velocity.x = lunge_dir * 450.0 # Heavy lunge

func _perform_shout_knockback():
	print("BOSS SHOUT! Triggering Phase 2 transition.")
	# Impactful knockback on player if nearby
	if is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist < 70:
			var dir = (target_player.global_position - global_position).normalized()
			if target_player.has_method("receive_hit"):
				# Apply damage first (which might reset velocity)
				target_player.receive_hit(5, self)
				# Apply a damage-safe knockback
				target_player.velocity = dir * 400
				if target_player.has_method("move_and_slide"):
					target_player.move_and_slide()


func get_anim(anim_name: String) -> String:
	var flame_anim = anim_name + "(flame)"
	if is_phase_2 and sprite.sprite_frames.has_animation(flame_anim):
		return flame_anim
	return anim_name

func _on_animation_finished():
	activate_hitbox("", false)
	match current_state:
		State.COMBAT:
			if sprite.animation == get_anim("atk1"):
				_start_attack("atk2")
			elif sprite.animation == get_anim("atk2"):
				_start_attack("atk3")
			else:
				change_state(State.IDLE)
		State.DEFEND:
			if sprite.animation == get_anim("defend"):
				sprite.stop()
				sprite.frame = 0
		State.SHOUT:
			change_state(State.IDLE)
		State.HURT:
			pass # Process handles recovery
		State.DEATH:
			handle_death(global_position)
			queue_free()

func _update_facing(dir_x: float) -> void:
	if dir_x == 0: return
	sprite.flip_h = dir_x < 0
	ray_cast.position.x = 20 if dir_x > 0 else -20
	update_combat_facing()

func _update_animations() -> void:
	if current_state in [State.COMBAT, State.DEFEND, State.SHOUT, State.HURT, State.DEATH, State.PRE_ATTACK]:
		return
	
	if abs(velocity.x) > 10:
		sprite.play(get_anim("run"))
	else:
		sprite.play(get_anim("idle"))

func receive_hit(damage: float, attacker: Node2D) -> float:
	var final_damage = damage
	var was_blocked = false

	if current_state == State.DEFEND:
		# Check if the hit is from the front
		var dir_to_attacker = sign(attacker.global_position.x - global_position.x)
		var is_facing_right = not sprite.flip_h
		var hit_from_front = (is_facing_right and dir_to_attacker > 0) or (not is_facing_right and dir_to_attacker < 0)

		if hit_from_front:
			was_blocked = true
			sprite.stop()
			sprite.play(get_anim("defend")) # Show the block on hit
			final_damage *= 0.1 # 90% damage reduction
			print("BOSS BLOCKED! (Frontal Hit) Reduced damage: ", final_damage)

			# Apply a knockback to the player
			if is_instance_valid(attacker):
				var knockback_dir = (attacker.global_position - global_position).normalized()
				attacker.velocity = knockback_dir * 400.0
				if attacker.has_method("move_and_slide"):
					attacker.move_and_slide()

			if is_phase_2:
				# We only subtract HP here and let the HP threshold check handle the shout
				# This prevents double-calling and ensures correct spacing
				pass
		else:
			print("BOSS HIT FROM BEHIND! Guard bypassed.")
			# New: Face the attacker when hit from behind during block
			_update_facing(dir_to_attacker)


	super.receive_hit(final_damage, attacker)

	if health <= 0:
		change_state(State.DEATH)
		return final_damage

	# Phase 1 Defensive Thresholds (every 125 HP / 25% of Phase 1 pool)
	if not is_phase_2 and health <= next_phase1_block_hp and health > max_health * 0.5:
		next_phase1_block_hp -= max_health * 0.125 # Next threshold (1000 * 0.125 = 125)
		print("BOSS PHASE 1 DEFENSE TRIGGER! Next at: ", next_phase1_block_hp)
		if is_instance_valid(attacker):
			var dir_to_attacker = sign(attacker.global_position.x - global_position.x)
			_update_facing(dir_to_attacker)
		change_state(State.DEFEND)
		return final_damage

	# Phase 2 Transition Check
	if not is_phase_2 and health <= max_health * health_threshold_phase_2:
		is_phase_2 = true
		speed *= phase_2_speed_mult
		# Set up next 5 shouts at every 10% interval
		next_shout_hp = max_health * 0.4 
		change_state(State.SHOUT)
		return final_damage

	# Phase 2 Threshold Shouts (5 times)
	if is_phase_2 and health <= next_shout_hp and health > 0:
		next_shout_hp -= max_health * 0.1 # Lower threshold for next shout
		print("BOSS HP THRESHOLD SHOUT! Next at: ", next_shout_hp)
		change_state(State.SHOUT)
		return final_damage

	# Note: Boss is now a Juggernaut (Super Armor).
	# We no longer change_state(State.HURT) except for blocked hits which already return early.
	if not was_blocked and current_state != State.SHOUT:
		play_hit_flash()

	return final_damage

func play_hit_flash():
	if not sprite: return
	
	var tween = create_tween()
	# Intensified white flash (values above 1.0 wash out colors to white in Godot)
	sprite.modulate = Color(15, 15, 15, 1) 
	# Transition back to normal (Color.WHITE) over 0.15 seconds for a smoother effect
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func play_telegraph_flash():
	if not sprite: return
	
	var tween = create_tween()
	# Bright Yellow Flash
	sprite.modulate = Color(4, 4, 0, 1) 
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)

func _on_detection_area_body_entered(body: Node2D):
	if body.is_in_group("player"):
		target_player = body

func _on_detection_area_body_exited(body: Node2D):
	if target_player == body:
		target_player = null

func _on_attack_area_area_entered(area: Area2D):
	if area.name == "Hurtbox" and area.owner.has_method("receive_hit") and area.owner != self:
		var target = area.owner
		if is_instance_valid(target) and target.is_in_group("player"):
			var profile = _get_active_profile()
			var damage = profile.get("damage", 10.0)
			if is_phase_2:
				damage *= 2.0
			target.receive_hit(damage, self)
