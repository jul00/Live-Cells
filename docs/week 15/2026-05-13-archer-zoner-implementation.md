# Archer Zoner Enemy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement an AI-controlled Archer enemy with zoner behavior (reactive back-pedaling, strategic retreat, combo-based attacks, and roaming with ledge detection).

**Architecture:** Priority-based behavior loop (Survival > Spacing > Execution > Roam) implemented in GDScript, using a `RayCast2D` for ledge detection and a `Marker2D` for projectile spawning.

**Tech Stack:** Godot 4.x (GDScript), CharacterBody2D.

---

## File Map

- Create: `scenes/arrow.tscn` (Projectile Area2D)
- Create: `scripts/arrow.gd` (Projectile logic)
- Create: `scripts/archer_enemy.gd` (AI Logic)
- Modify: `scenes/archer_enemy.tscn` (Add Muzzle, Timer, Detection Area)

---

## Tasks

### Task 1: Projectile Implementation (Arrow)

**Files:**
- Create: `scenes/arrow.tscn`
- Create: `scripts/arrow.gd`

- [ ] **Step 1: Create `scripts/arrow.gd`**
```gdscript
extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("receive_hit"):
		body.receive_hit(10.0) # Base damage
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
```

- [ ] **Step 2: Create `scenes/arrow.tscn`**
    - Root: `Area2D` (with `scripts/arrow.gd`)
    - Child: `Sprite2D` (use a small rectangle or arrow asset)
    - Child: `CollisionShape2D` (small circle/capsule)
    - Child: `VisibleOnScreenNotifier2D` (to cleanup off-screen)
    - Connect `body_entered` and `screen_exited` signals.

- [ ] **Step 3: Commit**
```bash
git add scripts/arrow.gd scenes/arrow.tscn
git commit -m "feat: implement arrow projectile"
```

### Task 2: Archer Scene Setup

**Files:**
- Modify: `scenes/archer_enemy.tscn`

- [ ] **Step 1: Add Muzzle**
    - Add `Marker2D` as child of `ArcherEnemy`. Name it `Muzzle`.
    - Position it in front of the sprite.

- [ ] **Step 2: Add Attack Timer**
    - Add `Timer` as child of `ArcherEnemy`. Name it `AttackTimer`.
    - Set `One Shot = true`.

- [ ] **Step 3: Add Detection Area**
    - Add `Area2D` as child of `ArcherEnemy`. Name it `DetectionArea`.
    - Add `CollisionShape2D` (large circle) to define the engagement range.

- [ ] **Step 4: Commit**
```bash
git add scenes/archer_enemy.tscn
git commit -m "feat: setup archer scene components"
```

### Task 3: Archer AI - Basic Movement & Roaming

**Files:**
- Create: `scripts/archer_enemy.gd`
- Modify: `scenes/archer_enemy.tscn` (Attach script)

- [ ] **Step 1: Implement Base Variables and Roam Logic**
```gdscript
extends CharacterBody2D

@export var speed = 100.0
@export var roam_speed = 50.0
@export var danger_zone_dist = 150.0
@export var engagement_zone_dist = 400.0

@onready var sprite = $AnimatedSprite2D
@onready var ray_cast = $RayCast2D
@onready var muzzle = $Muzzle
@onready var attack_timer = $AttackTimer

var target_player: CharacterBody2D = null
var roam_target: Vector2 = Vector2.ZERO
var is_roaming = false

func _physics_process(delta: float) -> void:
	if target_player:
		handle_zoner_behavior(delta)
	else:
		handle_roam_behavior(delta)
	
	move_and_slide()
	update_animations()

func handle_roam_behavior(delta: float) -> void:
	if not is_roaming:
		pick_roam_point()
	
	var dir = (roam_target - global_position).normalized()
	velocity.x = dir.x * roam_speed
	sprite.flip_h = velocity.x < 0
	
	# Ledge Detection
	if not ray_cast.is_colliding():
		# Stop and flip
		velocity.x = 0
		is_roaming = false
		pick_roam_point() # Will pick in opposite direction

	if global_position.distance_to(roam_target) < 10:
		is_roaming = false

func pick_roam_point():
	var random_dir = 1 if randf() > 0.5 else -1
	roam_target = global_position + Vector2(random_dir * randf_range(50, 200), 0)
	is_roaming = true

func update_animations():
	if abs(velocity.x) > 0:
		sprite.play("run")
	else:
		sprite.play("idle")
```

- [ ] **Step 2: Verify Roam and Ledge Detection**
    - Place Archer on a platform with an edge.
    - Ensure it wanders and turns around at the ledge.

- [ ] **Step 3: Commit**
```bash
git add scripts/archer_enemy.gd scenes/archer_enemy.tscn
git commit -m "feat: implement archer roam and ledge detection"
```

### Task 4: Archer AI - Zoner Spacing & Combat

**Files:**
- Modify: `scripts/archer_enemy.gd`

- [ ] **Step 1: Implement `handle_zoner_behavior`**
```gdscript
var combo_count = 0
var arrow_scene = preload("res://scenes/arrow.tscn")

func handle_zoner_behavior(delta: float) -> void:
	var dist = global_position.distance_to(target_player.global_position)
	var dir_to_player = (target_player.global_position - global_position).normalized()
	
	if dist < danger_zone_dist:
		# Survival: Immediate Retreat
		velocity.x = -dir_to_player.x * speed
		sprite.flip_h = velocity.x < 0
	elif dist < engagement_zone_dist:
		# Spacing: Back-pedal and Attack
		velocity.x = -dir_to_player.x * roam_speed
		sprite.flip_h = velocity.x < 0
		try_attack()
	else:
		# Out of range: Move toward player slowly
		velocity.x = dir_to_player.x * roam_speed
		sprite.flip_h = velocity.x < 0

func try_attack():
	if attack_timer.is_stopped():
		if combo_count >= 3:
			execute_attack("special-attack")
			combo_count = 0
		else:
			execute_attack("attack")
			combo_count += 1

func execute_attack(anim_name: String):
	sprite.play(anim_name)
	attack_timer.start()
	
	if anim_name == "attack":
		spawn_arrow(0)
	else:
		spawn_arrow(-15)
		spawn_arrow(0)
		spawn_arrow(15)

func spawn_arrow(angle_offset: float):
	var arrow = arrow_scene.instantiate()
	get_tree().root.add_child(arrow)
	arrow.global_position = muzzle.global_position
	
	var base_dir = (target_player.global_position - muzzle.global_position).normalized()
	var rotated_dir = base_dir.rotated(deg_to_rad(angle_offset))
	arrow.direction = rotated_dir
	arrow.rotation = rotated_dir.angle()
```

- [ ] **Step 2: Implement Player Detection**
    - Connect `DetectionArea` signals `body_entered` and `body_exited` to set `target_player`.

- [ ] **Step 3: Verify Combat Cycle**
    - Test that Archer retreats when close.
    - Test that Archer fires arrows at intervals.
    - Test that 4th attack is a Fan Shot.

- [ ] **Step 4: Commit**
```bash
git add scripts/archer_enemy.gd
git commit -m "feat: implement archer zoner spacing and combat logic"
```
