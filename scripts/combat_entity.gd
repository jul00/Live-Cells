extends CharacterBody2D
class_name CombatEntity

const HIT_FX = preload("res://scenes/fx/hit_particles.tscn")
const DEATH_FX = preload("res://scenes/fx/death_particles.tscn")

@export var health: float = 100.0
@export var faces_left_by_default: bool = false
@export var hitbox_profiles: Dictionary = {} # Format: {"id": {"pos": Vector2, "size": Vector2, "damage": float}}
@export var hit_particle_color: Color = Color.WHITE

var current_active_profile_id: String = ""
var is_dead: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = get_node_or_null("AttackArea")
@onready var attack_shape = get_node_or_null("AttackArea/CollisionShape2D")
@onready var hurtbox_shape = get_node_or_null("Hurtbox/CollisionShape2D")

func _ready():
	if attack_area:
		attack_area.monitoring = false
		attack_area.monitorable = false
	if has_node("Hurtbox"):
		var hb = get_node("Hurtbox")
		hb.monitoring = false
		hb.monitorable = true
		
	if attack_shape and attack_shape.shape:
		attack_shape.shape = attack_shape.shape.duplicate()

func spawn_particles(scene: PackedScene, pos: Vector2, color: Color = Color.WHITE, rot: float = 0.0):
	var fx = scene.instantiate()
	get_tree().root.add_child(fx)
	fx.global_position = pos
	fx.modulate = color
	fx.rotation = rot

func receive_hit(damage: float, attacker: Node2D) -> float:
	if health <= 0 or is_dead:
		return 0.0
		
	health -= damage
	
	# Trigger Hit Stop (0.05s)
	var lm = get_node_or_null("/root/LootManager")
	if lm:
		lm.trigger_hit_stop(0.05)
		
	# Trigger Hit Sound
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("hit")
	
	# Calculate direction of spray (away from attacker)
	var spray_rot = 0.0
	if is_instance_valid(attacker):
		var dir = (global_position - attacker.global_position).normalized()
		spray_rot = dir.angle()
	
	# Spawn particles at a consistent height (-16)
	spawn_particles(HIT_FX, global_position + Vector2(0, -16), hit_particle_color, spray_rot)
	print(name, " took hit! Health: ", health)
	return damage

func _on_attack_area_area_entered(area: Area2D):
	if area.name == "Hurtbox" and area.owner.has_method("receive_hit") and area.owner != self:
		var target = area.owner
		var is_attacker_player = is_in_group("player")
		var is_attacker_enemy = is_in_group("enemy")
		var is_target_player = target.is_in_group("player")
		var is_target_enemy = target.is_in_group("enemy")
		
		# Only allow Player -> Enemy or Enemy -> Player
		if (is_attacker_player and is_target_enemy) or (is_attacker_enemy and is_target_player):
			var profile = _get_active_profile()
			var damage = profile["damage"] if profile else 10.0
			target.receive_hit(damage, self)

func update_combat_facing():
	if not sprite: return
	
	# Determine if we are currently facing LEFT
	# If native is RIGHT (faces_left=false): flip_h=true means LEFT
	# If native is LEFT (faces_left=true): flip_h=false means LEFT
	var is_facing_left = sprite.flip_h if not faces_left_by_default else not sprite.flip_h
	
	# Mirror Attack Area based on the active profile's base position
	if attack_shape:
		var profile = _get_active_profile()
		if profile:
			var base_pos_x = profile["pos"].x
			attack_shape.position.x = -base_pos_x if is_facing_left else base_pos_x
	
	# Mirror Hurtbox if it's not centered (assume native pos is positive X)
	if hurtbox_shape:
		var native_pos_x = abs(hurtbox_shape.position.x)
		if native_pos_x > 0.1: # Only flip if significantly off-center
			hurtbox_shape.position.x = -native_pos_x if is_facing_left else native_pos_x

func activate_hitbox(profile_name: String, active: bool):
	if active:
		if not hitbox_profiles.has(profile_name):
			return
		current_active_profile_id = profile_name
	else:
		current_active_profile_id = ""
		
	if attack_area:
		attack_area.monitoring = active
	
	if active and attack_shape:
		var profile = hitbox_profiles[profile_name]
		attack_shape.position = profile["pos"]
		if attack_shape.shape and profile.has("size"):
			if attack_shape.shape is RectangleShape2D:
				attack_shape.shape.size = profile["size"]
			elif attack_shape.shape is CircleShape2D:
				attack_shape.shape.radius = profile["size"].x / 2.0
		update_combat_facing()

func _get_active_profile() -> Dictionary:
	if current_active_profile_id == "" or not hitbox_profiles.has(current_active_profile_id):
		return {}
	return hitbox_profiles[current_active_profile_id]

func handle_death(spawn_pos: Vector2):
	if is_dead:
		return
	spawn_particles(DEATH_FX, spawn_pos)
	is_dead = true
	var lm = get_node_or_null("/root/LootManager")
	if lm:
		get_tree().create_timer(0.5).timeout.connect(func():
			lm.spawn_loot(spawn_pos)
		)

func perform_look_around():
	await get_tree().create_timer(0.5).timeout
	if is_dead or not sprite: return
	
	sprite.flip_h = !sprite.flip_h
	update_combat_facing()
	
	await get_tree().create_timer(0.8).timeout
	if is_dead or not sprite: return
	
	sprite.flip_h = !sprite.flip_h
	update_combat_facing()
