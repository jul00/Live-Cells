# scripts/enemy_spawner.gd
extends Marker2D

@export_group("Spawn Configuration")
## List of enemy scenes this spawner can choose from
@export var enemy_scenes: Array[PackedScene] = []
## Time between spawns in seconds
@export var spawn_interval: float = 0.5
## Maximum number of enemies this spawner allows to be alive at once
@export var max_enemies: int = 30
## Randomize spawn position horizontally by this amount
@export var spawn_width: float = 200.0

@export_group("Marker Configuration")
## If true, uses nodes in a specific group as spawn points
@export var use_marker_group: bool = true
## The group name for spawn point markers
@export var marker_group_name: String = "enemy_spawn_point"

@export_group("Platform Constraints")
## If true, ensures the spawn location has a solid platform underneath
@export var require_platform: bool = true
## Minimum width check in pixels (e.g., 48px for 3x16px tiles)
@export var min_platform_width: float = 48.0
## Max distance to look for a floor
@export var floor_max_distance: float = 100.0

@onready var timer = $SpawnTimer

var spawned_enemies: Array[Node2D] = []
## Tracks markers that have already spawned an enemy to avoid respawning
var vanquished_markers: Dictionary = {}

func _ready() -> void:
	# Ensure the timer is configured
	if not timer:
		timer = Timer.new()
		add_child(timer)
		timer.name = "SpawnTimer"
	
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_spawn_timeout)
	timer.start()

func spawn_enemy() -> void:
	print("Spawner: Attempting to spawn...")
	# 1. Clean up tracking
	spawned_enemies = spawned_enemies.filter(func(e): return is_instance_valid(e))
	
	# 2. Check limits
	if spawned_enemies.size() >= max_enemies:
		print("Spawner: Limit reached (", spawned_enemies.size(), "/", max_enemies, ")")
		return
	if enemy_scenes.is_empty():
		print("Spawner: No enemy scenes configured!")
		return
		
	# 3. Attempt to find a valid spawn position
	var spawn_pos = _find_valid_spawn_pos()
	if spawn_pos == Vector2.ZERO:
		print("Spawner: No valid spawn position found")
		return
		
	# 4. Pick and instance
	var scene = enemy_scenes.pick_random()
	var enemy = scene.instantiate() as CharacterBody2D
	enemy.global_position = spawn_pos
	
	# 5. Add to scene tree
	var container = get_tree().current_scene
	container.add_child(enemy)
	spawned_enemies.append(enemy)
	print("Spawner: Spawned ", enemy.name, " at ", spawn_pos)

func _find_valid_spawn_pos() -> Vector2:
	if use_marker_group:
		var markers = get_tree().get_nodes_in_group(marker_group_name)
		
		# 1. Filter out already used/vanquished markers
		var available_markers = markers.filter(func(m): return not vanquished_markers.has(m.get_instance_id()))
		
		if not available_markers.is_empty():
			# 2. Find the player to calculate proximity
			var player = get_tree().get_first_node_in_group("player")
			
			if player:
				# 3. Sort by distance to player
				available_markers.sort_custom(func(a, b):
					var dist_a = a.global_position.distance_to(player.global_position)
					var dist_b = b.global_position.distance_to(player.global_position)
					return dist_a < dist_b
				)
			
			# 4. Pick the nearest available marker
			var target_marker = available_markers[0]
			
			# 5. Mark as vanquished (one-time use)
			vanquished_markers[target_marker.get_instance_id()] = true
			
			print("Spawner: Using nearest marker ", target_marker.name, " at ", target_marker.global_position)
			return target_marker.global_position
	
	print("Spawner: No available markers in group, using fallback random logic")
	for attempt in range(5):
		var test_x = global_position.x + randf_range(-spawn_width, spawn_width)
		var test_pos = Vector2(test_x, global_position.y)
		
		if not require_platform:
			return test_pos
			
		# Perform 3-point check for platform width
		var floor_y = _check_platform_at(test_pos)
		if floor_y != -1.0:
			return Vector2(test_x, floor_y - 5) # Offset slightly above floor
			
	return Vector2.ZERO

## Returns the Y coordinate of the floor if a valid platform of min_platform_width exists.
## Returns -1.0 if invalid.
func _check_platform_at(pos: Vector2) -> float:
	var space_state = get_world_2d().direct_space_state
	
	# We check 3 points: Center, Left Edge, Right Edge
	var half_width = min_platform_width / 2.0
	var points_to_check = [
		pos, # Center
		pos + Vector2(-half_width, 0), # Left
		pos + Vector2(half_width, 0) # Right
	]
	
	var found_y = -1.0
	
	for p in points_to_check:
		var query = PhysicsRayQueryParameters2D.create(p, p + Vector2(0, floor_max_distance))
		# Exclude enemies and player from floor check (collision mask 1 is usually terrain)
		query.collision_mask = 1 
		
		var result = space_state.intersect_ray(query)
		
		if result.is_empty():
			return -1.0 # One of the edges is over a hole
		
		# Ensure all points hit roughly the same height (flat surface)
		if found_y == -1.0:
			found_y = result.position.y
		elif abs(found_y - result.position.y) > 10.0:
			return -1.0 # Surface is too uneven/sloped
			
	return found_y

func _on_spawn_timeout() -> void:
	spawn_enemy()
