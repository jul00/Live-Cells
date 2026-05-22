# Grappler Enemy State Machine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a state machine for the Grappler enemy with idle, roam, and attack states, including a chance to chain attacks and slide forward during attacks.

**Architecture:** A state machine driven by an `enum State` inside `_physics_process`. Uses the existing animations (`idle`, `walk`, `atk1`, `atk2`). The attack has a 33% chance to chain from `atk1` to `atk2`. A small forward velocity impulse is applied at the start of each attack animation to simulate a heavy, sliding attack.

**Tech Stack:** Godot 4.x (GDScript), CharacterBody2D.

---

## File Map

- Modify: `scripts/grappler_enemy.gd`
- Modify: `scenes/grappler_enemy.tscn` (Minor updates to connect signals or add detection if needed, but primarily script changes)

---

## Tasks

### Task 1: Base State Machine & Roaming

**Files:**
- Modify: `scripts/grappler_enemy.gd`

- [ ] **Step 1: Define States and Variables**
Replace the default player-input script with a base state machine.

```gdscript
extends CharacterBody2D

enum State { IDLE, ROAM, ATTACK }

@export var speed: float = 80.0
@export var gravity_multiplier: float = 1.0

@onready var sprite = $AnimatedSprite2D
@onready var ray_cast = $RayCast2D

var current_state = State.IDLE
var target_player: CharacterBody2D = null
var is_roaming = false
var roam_target = Vector2.ZERO
var state_timer = 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	match current_state:
		State.IDLE:
			process_idle(delta)
		State.ROAM:
			process_roam(delta)
		State.ATTACK:
			process_attack(delta)

	move_and_slide()
	update_animations()

func change_state(new_state: State) -> void:
	current_state = new_state
	state_timer = 0.0

func process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 400 * delta)
	state_timer += delta
	if state_timer > 2.0:
		change_state(State.ROAM)

func process_roam(delta: float) -> void:
	pass # To be implemented in next step

func process_attack(delta: float) -> void:
	pass # To be implemented later

func update_animations() -> void:
	if current_state == State.ATTACK:
		return
	if abs(velocity.x) > 10:
		sprite.play("walk")
	else:
		sprite.play("idle")
```

- [ ] **Step 2: Implement Roaming Logic**
Update `process_roam` to pick a point, move towards it, and handle ledge detection.

```gdscript
func process_roam(delta: float) -> void:
	if not is_roaming:
		var dir = 1 if randf() > 0.5 else -1
		roam_target = global_position + Vector2(dir * randf_range(50, 150), 0)
		is_roaming = true
		sprite.flip_h = dir < 0
		# Update raycast to face the direction we are moving
		ray_cast.position.x = -18 if sprite.flip_h else 18
	
	var dir_x = 1 if not sprite.flip_h else -1
	velocity.x = dir_x * speed
	
	# Ledge detection
	if is_on_floor() and not ray_cast.is_colliding():
		velocity.x = 0
		is_roaming = false
		change_state(State.IDLE)
		return
		
	if abs(roam_target.x - global_position.x) < 10:
		velocity.x = 0
		is_roaming = false
		change_state(State.IDLE)
```

- [ ] **Step 3: Commit**
```bash
git add scripts/grappler_enemy.gd
git commit -m "feat: implement grappler base state machine and roam"
```

### Task 2: Player Detection & Attack Setup

**Files:**
- Modify: `scenes/grappler_enemy.tscn`
- Modify: `scripts/grappler_enemy.gd`

- [ ] **Step 1: Add Detection Area to Scene**
Since the grappler needs to know when to attack, add an Area2D to detect the player. (Assuming the engineer opens the scene in Godot or modifies the script to add it dynamically. We will use a script-based distance check to avoid `.tscn` conflicts, assuming the player can be found or passed in). 
*Alternative: We will just add a simple distance check in the script by finding the player node.*

```gdscript
@export var attack_range: float = 60.0
@export var detection_range: float = 200.0

func _physics_process(delta: float) -> void:
	# Add gravity...
	
	# Find player (assuming a single player group or node name "Player" in the tree)
	# For simplicity, we'll try to find a node named "Player" in the scene
	if not target_player:
		var player_node = get_tree().get_first_node_in_group("player")
		if not player_node:
			# Fallback if no group is used, just look for the Player node
			player_node = get_tree().root.find_child("Player", true, false)
		if player_node is CharacterBody2D:
			target_player = player_node

	if target_player and current_state != State.ATTACK:
		var dist = global_position.distance_to(target_player.global_position)
		if dist < attack_range:
			change_state(State.ATTACK)
			
	# ... rest of physics process
```

- [ ] **Step 2: Connect Animation Signal**
In `_ready()`, connect the `animation_finished` signal.

```gdscript
func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
```

- [ ] **Step 3: Commit**
```bash
git add scripts/grappler_enemy.gd
git commit -m "feat: add player distance detection for grappler"
```

### Task 3: Chaining Attacks & Sliding

**Files:**
- Modify: `scripts/grappler_enemy.gd`

- [ ] **Step 1: Implement `process_attack` and Sliding**

```gdscript
@export var slide_speed: float = 150.0
var will_chain_attack = false
var is_sliding = false

func change_state(new_state: State) -> void:
	current_state = new_state
	state_timer = 0.0
	
	if current_state == State.ATTACK:
		will_chain_attack = randf() <= 0.33
		start_attack("atk1")

func start_attack(anim_name: String) -> void:
	sprite.play(anim_name)
	
	# Face the player if possible
	var dir_x = 1 if not sprite.flip_h else -1
	if target_player:
		dir_x = 1 if target_player.global_position.x > global_position.x else -1
		sprite.flip_h = dir_x < 0
	
	# Apply forward slide impulse
	velocity.x = dir_x * slide_speed
	is_sliding = true

func process_attack(delta: float) -> void:
	# Apply heavy friction to the slide
	if is_sliding:
		velocity.x = move_toward(velocity.x, 0, 600 * delta)
		if velocity.x == 0:
			is_sliding = false
```

- [ ] **Step 2: Implement Animation Chaining**

```gdscript
func _on_animation_finished() -> void:
	if current_state == State.ATTACK:
		if sprite.animation == "atk1" and will_chain_attack:
			# Chain into atk2
			start_attack("atk2")
			will_chain_attack = false # Don't chain infinitely
		else:
			# Attack finished
			change_state(State.IDLE)
```

- [ ] **Step 3: Commit**
```bash
git add scripts/grappler_enemy.gd
git commit -m "feat: implement grappler combo chaining and slide mechanic"
```
