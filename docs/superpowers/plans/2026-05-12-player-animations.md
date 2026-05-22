# Player Animation & Combat System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a state-driven animation and combat system for the player including a buffered attack combo chain, special abilities, and a multi-stage jump sequence.

**Architecture:** A simple Finite State Machine (FSM) integrated into `player.gd` to manage mutually exclusive animation states. Combat uses a combo-step counter and a buffering flag to allow fluid transitions between attack animations.

**Tech Stack:** Godot 4.x (GDScript), AnimatedSprite2D.

---

## File Map
- Modify: `scripts/player.gd` - Main logic for state machine, input handling, and animation triggering.

---

## Task 1: State Machine Foundation

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Define States and Base Variables**
Add the `State` enum and state tracking variables to the top of `player.gd`.

```gdscript
enum State { MOVE, JUMP, ATTACK, DASH, DEFEND, HURT, DEATH }
var current_state = State.MOVE

@onready var sprite = →AnimatedSprite2D
```

- [ ] **Step 2: Implement State Transition Function**
Add a helper function `change_state` to handle animation triggers and state entry logic.

```gdscript
func change_state(new_state: State):
	current_state = new_state
	match current_state:
		State.MOVE:
			pass # Handled in _physics_process
		State.JUMP:
			sprite.play("jump-start")
		State.ATTACK:
			pass # Handled by combo logic
		State.DASH:
			sprite.play("dash")
		State.DEFEND:
			sprite.play("defend")
		State.HURT:
			sprite.play("hurt")
		State.DEATH:
			sprite.play("death")
```

- [ ] **Step 3: Integrate State Check in _physics_process**
Wrap the existing movement logic to only run when in `State.MOVE` or `State.JUMP`.

```gdscript
func _physics_process(delta: float) -> void:
	if current_state == State.DEATH:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if current_state == State.MOVE or current_state == State.JUMP:
		handle_movement_input()
	
	handle_combat_input()
	
	move_and_slide()
	update_animations()
```

- [ ] **Step 4: Move movement logic to handle_movement_input()**
Refactor the movement and jump code into its own function.

```gdscript
func handle_movement_input():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(State.JUMP)

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
```

- [ ] **Step 5: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: implement base state machine for player"
```

---

## Task 2: Buffered Combat Combo System

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Define Combo Variables**
Add combo tracking variables to `player.gd`.

```gdscript
var combo_step = 0
var next_attack_queued = false
var attack_animations = ["atk1", "atk2", "atk3"]
```

- [ ] **Step 2: Implement Attack Trigger Logic**
Add the `attack()` function to handle the combo chain and buffering.

```gdscript
func attack():
	if current_state == State.JUMP:
		sprite.play("air-atk")
		return

	if current_state != State.ATTACK:
		combo_step = 0
		next_attack_queued = false
	
	combo_step = (combo_step + 1) % attack_animations.size()
	change_state(State.ATTACK)
	sprite.play(attack_animations[combo_step])

func handle_combat_input():
	if Input.is_action_just_pressed("attack"):
		if current_state == State.ATTACK:
			# Check if we are in the buffer window (last 30% of animation)
			var frame_count = sprite.sprite_frames.get_frame_count(sprite.animation)
			if sprite.frame >= floor(frame_count * 0.7):
				next_attack_queued = true
		else:
			attack()
```

- [ ] **Step 3: Implement Animation Finished Signal**
Connect the `animation_finished` signal of `AnimatedSprite2D` to handle combo transitions.

```gdscript
# In _ready()
func _ready():
	sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	if current_state == State.ATTACK:
		if next_attack_queued:
			next_attack_queued = false
			combo_step = (combo_step + 1) % attack_animations.size()
			sprite.play(attack_animations[combo_step])
		else:
			change_state(State.MOVE)
	elif current_state == State.DASH:
		change_state(State.MOVE)
	elif current_state == State.HURT:
		change_state(State.MOVE)
```

- [ ] **Step 4: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: implement buffered combat combo system"
```

---

## Task 3: Special Abilities (Dash, Defend, Special)

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Implement Special Attack**
Add logic for the high-priority special attack.

```gdscript
# inside handle_combat_input()
	if Input.is_action_just_pressed("special"):
		change_state(State.ATTACK)
		sprite.play("special-atk")
		next_attack_queued = false
		combo_step = 0
```

- [ ] **Step 2: Implement Dash Logic**
Add dashing with movement lock.

```gdscript
# inside handle_combat_input()
	if Input.is_action_just_pressed("dash"):
		change_state(State.DASH)
		# Apply a dash burst velocity
		var dash_dir = -1 if sprite.flip_h else 1
		velocity.x = dash_dir * SPEED * 2
```

- [ ] **Step 3: Implement Defend Logic**
Add hold-to-defend logic.

```gdscript
# inside handle_combat_input()
	if Input.is_action_pressed("defend"):
		change_state(State.DEFEND)
	elif current_state == State.DEFEND:
		change_state(State.MOVE)
```

- [ ] **Step 4: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: implement dash, defend, and special attack"
```

---

## Task 4: Advanced Jump Animations & Final Polish

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Implement Jump Animation Chaining**
Update the `update_animations` function to handle the jump sequence based on velocity.

```gdscript
func update_animations():
	match current_state:
		State.MOVE:
			if velocity.x == 0:
				sprite.play("idle")
			else:
				sprite.play("walk")
		State.JUMP:
			if velocity.y < 0:
				# Check if we just started or are transitioning
				if sprite.animation != "jump-start":
					sprite.play("jump-start")
			elif abs(velocity.y) < 50:
				sprite.play("jump-transition")
			else:
				sprite.play("jump-fall")
```

- [ ] **Step 2: Refine Jump Landing**
Ensure the player returns to `State.MOVE` when landing.

```gdscript
# inside _physics_process
	if current_state == State.JUMP and is_on_floor():
		change_state(State.MOVE)
```

- [ ] **Step 3: Final Polish and Testing**
Verify all transitions:
- Move →
?→ Jump →
?→ Air Atk →
?→ Fall →
?→ Land →
?→ Move.
- Move →
?→ Atk1 →
?→ Atk2 →
?→ Atk3 →
?→ Move.
- Move →
?→ Dash →
?→ Move.
- Move →
?→ Defend (hold) →
?→ Move.

- [ ] **Step 4: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: finalize jump animations and polish player state machine"
```
