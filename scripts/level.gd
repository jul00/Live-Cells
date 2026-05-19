# scripts/level.gd
extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var pitfall_respawn_marker = $"Pitfall Respawn"

@onready var pitfall1 = $pitfall1
@onready var pitfall2 = $pitfall2

var last_checkpoint_pos: Vector2 = Vector2.ZERO
var is_respawning: bool = false
var respawn_safety_timer: float = 0.0

func _ready() -> void:
	# Level script needs to handle respawn sequence even when paused
	process_mode = PROCESS_MODE_ALWAYS
	
	# Initial checkpoint is the respawn marker or player start
	last_checkpoint_pos = pitfall_respawn_marker.global_position
	
	# Connect pitfall1 (respawns at marker)
	pitfall1.body_entered.connect(_on_pitfall1_entered)
	
	# Connect pitfall2 (respawns at last checkpoint)
	pitfall2.body_entered.connect(_on_pitfall2_entered)
	
	# Connect all pitfall checkpoints
	for child in get_children():
		if child is Area2D and child.name.begins_with("pitfall checkpoint"):
			child.body_entered.connect(_on_checkpoint_entered.bind(child))

func _physics_process(delta: float) -> void:
	if respawn_safety_timer > 0:
		respawn_safety_timer -= delta

func _on_checkpoint_entered(body: Node2D, checkpoint: Area2D) -> void:
	if body.is_in_group("player"):
		last_checkpoint_pos = checkpoint.global_position
		print("Checkpoint updated to: ", checkpoint.name)

func _on_pitfall1_entered(body: Node2D) -> void:
	if body.is_in_group("player") and respawn_safety_timer <= 0:
		_respawn_player(pitfall_respawn_marker.global_position)

func _on_pitfall2_entered(body: Node2D) -> void:
	if body.is_in_group("player") and respawn_safety_timer <= 0:
		_respawn_player(last_checkpoint_pos)

func _respawn_player(pos: Vector2) -> void:
	if is_respawning:
		return
		
	is_respawning = true
	
	# Disable player processing and physics to avoid double triggers
	player.process_mode = PROCESS_MODE_DISABLED
	player.visible = false
	
	if ui.has_method("fade_to_black"):
		# Use ignore_time_scale=true to avoid hit-stop delays
		await ui.fade_to_black(0.2)
		
		# Move player and reset physics state
		player.global_position = pos
		player.velocity = Vector2.ZERO
		
		# Apply damage AFTER teleporting so particles/flash appear at checkpoint
		if player.has_method("receive_hit"):
			var max_hp = player.get("max_health") if player.get("max_health") != null else 1200.0
			var damage = max_hp * 0.2
			player.receive_hit(damage, self)
		
		# Wait a bit for the teleport to settle
		await get_tree().create_timer(0.3, true, false, true).timeout
		
		player.visible = true
		await ui.fade_from_black(0.2)
		
		# Re-enable player
		player.process_mode = PROCESS_MODE_INHERIT
	else:
		player.global_position = pos
		player.velocity = Vector2.ZERO
	
	# Set safety window to 1 second to prevent immediate re-triggering
	respawn_safety_timer = 1.0
	
	# Ensure physics has a chance to update before allowing another respawn
	await get_tree().physics_frame
	await get_tree().physics_frame
	is_respawning = false
