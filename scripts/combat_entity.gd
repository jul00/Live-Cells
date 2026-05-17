extends CharacterBody2D
class_name CombatEntity

@export var health: float = 100.0
@export var faces_left_by_default: bool = false
@export var hitbox_profiles: Dictionary = {} # Format: {"id": {"pos": Vector2, "size": Vector2, "damage": float}}

var current_active_profile_id: String = ""
var is_dead: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/CollisionShape2D
@onready var hurtbox_shape = $Hurtbox/CollisionShape2D

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

func receive_hit(damage: float, attacker: Node2D) -> float:
	health -= damage
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
	is_dead = true
	if LootManager:
		get_tree().create_timer(0.8).timeout.connect(func():
			LootManager.spawn_loot(spawn_pos)
		)
