extends CombatEntity

enum State { IDLE, ROAM, APPROACH, PRE_ATTACK, ATTACK, COOLDOWN, DEATH}

@export var speed: float = 40.0
@export var gravity_multiplier: float = 1.0

@export_group("Combat")
@export var slide_speed: float = 300.0
@export_range(0, 500) var attack_range: float = 80.0
@export var detection_range: float = 200.0

@onready var ray_cast = $RayCast2D

var current_state = State.IDLE
var target_player: CharacterBody2D = null
var is_roaming = false
var roam_target = Vector2.ZERO
var state_timer = 0.0
var will_chain_attack = false
var is_sliding = false

func _ready() -> void:
	super._ready()
	faces_left_by_default = true
	health = 288.0
	hitbox_profiles = {
		"atk1": {"pos": Vector2(20, -36), "size": Vector2(70, 70), "damage": 120.0},
		"atk2": {"pos": Vector2(25, -36), "size": Vector2(60, 60), "damage": 120.0}
	}
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)

func _physics_process(delta: float) -> void:

	# 1. Global Gravity
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
			process_idle(delta)
		State.ROAM:
			process_roam(delta)
		State.APPROACH:
			process_approach(delta)
		State.PRE_ATTACK:
			_process_pre_attack(delta)
		State.COOLDOWN:
			process_cooldown(delta)
		State.ATTACK:
			process_attack(delta)

	move_and_slide()
	update_animations()

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
		
	# Exit logic
	match current_state:
		State.ROAM:
			is_roaming = false
		State.ATTACK:
			is_sliding = false
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
		State.PRE_ATTACK:
			velocity.x = 0
			sprite.play("idle")
		State.ATTACK:
			will_chain_attack = randf() <= 0.33
			start_attack("atk1")
		State.DEATH:
			velocity.x = 0
			activate_hitbox("", false)
			sprite.play("die")

func _evaluate_combat_state() -> void:
	if is_line_of_sight_blocked(target_player):
		if current_state != State.IDLE and current_state != State.ROAM:
			change_state(State.IDLE)
		return

	var dist = global_position.distance_to(target_player.global_position)
	
	if current_state == State.IDLE or current_state == State.ROAM:
		change_state(State.APPROACH)
	elif current_state == State.APPROACH:
		if dist <= attack_range:
			change_state(State.PRE_ATTACK)
	elif current_state == State.ATTACK:
		# Don't evaluate new states while attacking
		return
	elif current_state == State.COOLDOWN:
		if state_timer >= 1.0:
			change_state(State.APPROACH)

func start_attack(anim_name: String) -> void:
	sprite.play(anim_name)
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("hit")

	# Set position immediately so it's correct during the wind-up
	if hitbox_profiles.has(anim_name) and attack_shape:
		current_active_profile_id = anim_name
		attack_shape.position = hitbox_profiles[anim_name]["pos"]
		update_combat_facing()
		current_active_profile_id = "" # Clear it so update_combat_facing doesn't move it during wind-up
	
	# Calculate wind-up delay (0.5s for heavy opener, 0.3s for follow-up)
	var delay = 0.8 if anim_name == "atk1" else 0.3
	
	get_tree().create_timer(delay).timeout.connect(func():
		if current_state == State.ATTACK and sprite.animation == anim_name:
			activate_hitbox(anim_name, true)
	)
	
	velocity.x = 0
	is_sliding = false
	
	# Face player on attack start
	if is_instance_valid(target_player):
		var dir_x = 1 if target_player.global_position.x > global_position.x else -1
		_update_facing(dir_x)

func _process_pre_attack(delta: float) -> void:
	state_timer += delta
	# Yellow blinking effect: 0.1s intervals
	if int(state_timer * 10) % 2 == 0:
		sprite.modulate = Color(15, 15, 0, 1) # Yellow telegraph
	else:
		sprite.modulate = Color.WHITE
		
	if state_timer >= 0.7:
		sprite.modulate = Color.WHITE
		change_state(State.ATTACK)

func process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer > 2.0:
		change_state(State.ROAM)

func process_roam(_delta: float) -> void:
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

func process_approach(_delta: float) -> void:
	if not is_instance_valid(target_player):
		change_state(State.IDLE)
		return
		
	var dist_x = target_player.global_position.x - global_position.x
	var dir_x = 1 if dist_x > 0 else -1
	
	_update_facing(dir_x)
	velocity.x = dir_x * speed
	
	# Safety: don't walk off ledges while approaching
	if is_on_floor() and not ray_cast.is_colliding():
		velocity.x = 0
		return

func process_attack(delta: float) -> void:
	if is_sliding:
		velocity.x = move_toward(velocity.x, 0, 1200 * delta)
		if velocity.x == 0:
			is_sliding = false

func process_cooldown(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if is_instance_valid(target_player):
		var dir_x = 1 if target_player.global_position.x > global_position.x else -1
		_update_facing(dir_x)
	
	state_timer += delta
	if state_timer >= 1.0:
		if target_player:
			_evaluate_combat_state()
		else:
			change_state(State.IDLE)

func _update_facing(dir_x: float) -> void:
	if dir_x == 0: return
	# Native faces LEFT
	sprite.flip_h = dir_x > 0
	ray_cast.position.x = 18 if sprite.flip_h else -18
	update_combat_facing()

func _on_frame_changed() -> void:
	if current_state == State.ATTACK:
		var frame = sprite.frame
		var anim = sprite.animation
		# Trigger heavy dash at frame 3
		if (anim == "atk1" and frame == 3) or (anim == "atk2" and frame == 3):
			var dash_dir = 1 if sprite.flip_h else -1
			velocity.x = dash_dir * slide_speed
			is_sliding = true

func _on_animation_finished() -> void:
	activate_hitbox("", false)
	if current_state == State.ATTACK:
		if sprite.animation == "atk1" and will_chain_attack:
			start_attack("atk2")
			will_chain_attack = false
		else:
			change_state(State.COOLDOWN)
	elif current_state == State.DEATH:
		handle_death(global_position)
		queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if target_player == body:
		target_player = null

func update_animations() -> void:
	# Face direction of movement if not in combat states
	if current_state == State.ROAM and velocity.x != 0:
		_update_facing(velocity.x)

	if current_state in [State.ATTACK, State.DEATH]:
		return
	
	activate_hitbox("", false) # Safety cleanup
		
	if abs(velocity.x) > 10:
		sprite.play("walk")
	else:
		sprite.play("idle")

func receive_hit(damage: float, attacker: Node2D) -> float:
	var final_damage = super.receive_hit(damage, attacker)
	if health <= 0:
		change_state(State.DEATH)
	elif current_state in [State.PRE_ATTACK, State.ATTACK]:
		# Super Armor: Don't flinch (stay in attack/telegraph), just flash
		play_hit_flash()
	else:
		play_hit_flash()
	return final_damage

func play_hit_flash():
	if not sprite: return
	
	var tween = create_tween()
	# Intensified white flash (values above 1.0 wash out colors to white in Godot)
	sprite.modulate = Color(15, 15, 15, 1) 
	# Transition back to normal (Color.WHITE) over 0.15 seconds for a smoother effect
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
