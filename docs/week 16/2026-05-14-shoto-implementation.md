# Shoto Enemy State Machine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a balanced "Shoto" AI for the `shoto_enemy.tscn` with a 3-hit combo, a gap-closer, and defensive capabilities.

**Architecture:** FSM with states: `IDLE`, `ROAM`, `APPROACH` (Chasing), `COMBAT` (Close-range), and `DEFEND`.
- **Close Range:** 3-hit combo potential (`atk1` -> `atk2` -> `atk3`).
- **Mid Range:** Uses `dash-atk` (Tatsumaki) to close distance.
- **Defense:** Chance to enter `defend` state when in combat range.

**Tech Stack:** Godot 4.x (GDScript), CharacterBody2D.

---

## File Map

- Create: `scripts/shoto_enemy.gd`
- Modify: `scenes/shoto_enemy.tscn` (Attach script)

---

## Tasks

### Task 1: Basic State Machine & Movement

**Files:**
- Create: `scripts/shoto_enemy.gd`

- [ ] **Step 1: Implement State Machine and Roaming**
Similar to the Grappler but adjusted for the Shoto's native facing (which is right-facing).
```gdscript
extends CharacterBody2D

enum State { IDLE, ROAM, APPROACH, COMBAT, DEFEND }

@export var speed: float = 120.0 # Faster than grappler
@export var gravity_multiplier: float = 1.0
@export var combat_range: float = 50.0
@export var dash_range: float = 180.0

@onready var sprite = $AnimatedSprite2D
@onready var ray_cast = $RayCast2D

var current_state = State.IDLE
var target_player: CharacterBody2D = null
var state_timer = 0.0
var combo_step = 0

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta
	
	_find_player()
	
	match current_state:
		State.IDLE: process_idle(delta)
		State.ROAM: process_roam(delta)
		State.APPROACH: process_approach(delta)
		State.COMBAT: process_combat(delta)
		State.DEFEND: process_defend(delta)
	
	move_and_slide()
	_update_animations()

func change_state(new_state: State):
	current_state = new_state
	state_timer = 0.0
```

- [ ] **Step 2: Commit**
```bash
git add scripts/shoto_enemy.gd
git commit -m "feat: shoto base fsm and movement"
```

### Task 2: Advanced Combat (Combo & Dash)

**Files:**
- Modify: `scripts/shoto_enemy.gd`

- [ ] **Step 1: Implement 3-Hit Combo and Dash-Atk**
```gdscript
func process_combat(delta):
	velocity.x = move_toward(velocity.x, 0, 800 * delta)
	if combo_step == 0 and sprite.animation != "atk1":
		_start_attack("atk1")

func _start_attack(anim_name: String):
	sprite.play(anim_name)
	# Face player
	if is_instance_valid(target_player):
		sprite.flip_h = target_player.global_position.x < global_position.x

func _on_animation_finished():
	if current_state == State.COMBAT:
		if sprite.animation == "atk1":
			combo_step = 1
			_start_attack("atk2")
		elif sprite.animation == "atk2":
			combo_step = 2
			_start_attack("atk3")
		else:
			combo_step = 0
			change_state(State.IDLE)
```

- [ ] **Step 2: Add Gap Closer Logic**
If in `APPROACH` state and distance is mid-range, use `dash-atk`.
```gdscript
func process_approach(delta):
	var dist = global_position.distance_to(target_player.global_position)
	if dist < combat_range:
		change_state(State.COMBAT)
	elif dist < dash_range and randf() < 0.01: # Randomly dash-in
		_start_dash_attack()

func _start_dash_attack():
	sprite.play("dash-atk")
	velocity.x = (-200 if sprite.flip_h else 200) # Quick burst forward
```

- [ ] **Step 3: Commit**
```bash
git add scripts/shoto_enemy.gd
git commit -m "feat: implement shoto combo and gap closer"
```
