# Wall Climbing & Jumping Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate sticky wall climbing mechanics including initial contact, sliding, and a standard platformer wall jump.

**Architecture:**
- Introduce `State.WALL` to the player state machine.
- Implement wall detection and state transition in `_physics_process`.
- Use `AnimatedSprite2D` to sequence `wall-contact` →
?→ `wall-slide`.
- Apply capped gravity in `State.WALL` to simulate sliding.
- Implement diagonal impulse for wall jumping.

**Tech Stack:** Godot 4.x (GDScript).

---

## File Map
- Modify: `scripts/player.gd`

---

## Task 1: Wall State Foundation

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Add State and Constants**
Update the `State` enum and add constants for wall mechanics.

```gdscript
enum State { MOVE, JUMP, ATTACK, DASH, DEFEND, HURT, DEATH, WALL }
const WALL_SLIDE_SPEED = 100.0
const WALL_JUMP_PUSH = 200.0
```

- [ ] **Step 2: Update `change_state`**
Add the `State.WALL` transition and the default animation.

```gdscript
# Inside match current_state in change_state()
		State.WALL:
			sprite.play("wall-contact")
```

- [ ] **Step 3: Implement Wall Detection**
Add logic to `_physics_process` to enter `State.WALL` when in air and touching a wall.

```gdscript
func _physics_process(delta: float) -> void:
	# ... existing early return
	
	# Wall detection
	if not is_on_floor() and is_on_wall() and current_state != State.ATTACK:
		change_state(State.WALL)
	
	# ... existing gravity and state logic
```

- [ ] **Step 4: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: implement basic wall state and detection"
```

---

## Task 2: Wall Slide and Contact Logic

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Implement Capped Gravity for Sliding**
In `_physics_process`, modify the gravity application to cap the downward velocity when in `State.WALL`.

```gdscript
	# Add the gravity.
	if not is_on_floor():
		if current_state == State.WALL:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, get_gravity().y * delta)
		else:
			velocity += get_gravity() * delta
```

- [ ] **Step 2: Transition from Contact to Slide**
Update `_on_animation_finished` to transition from the `wall-contact` animation to the looping `wall-slide` animation.

```gdscript
func _on_animation_finished():
	# ... existing attack/dash/hurt logic
	if current_state == State.WALL and sprite.animation == "wall-contact":
		sprite.play("wall-slide")
```

- [ ] **Step 3: Handle Wall State Exit**
Update `_physics_process` to return to `State.JUMP` or `State.MOVE` if the player leaves the wall or hits the floor.

```gdscript
	# Inside _physics_process
	if current_state == State.WALL:
		if is_on_floor():
			change_state(State.MOVE)
		elif not is_on_wall():
			change_state(State.JUMP)
```

- [ ] **Step 4: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: implement wall sliding and contact animations"
```

---

## Task 3: Wall Jump Implementation

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Implement Wall Jump Input**
Update `handle_movement_input` or create a new input handler to trigger the wall jump when in `State.WALL`.

```gdscript
func handle_movement_input():
	if Input.is_action_just_pressed("Jump"):
		if current_state == State.WALL:
			# Wall Jump: push away from wall and up
			var wall_normal = get_wall_normal()
			velocity = Vector2(wall_normal.x * WALL_JUMP_PUSH, JUMP_VELOCITY)
			change_state(State.JUMP, "wall-jump")
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY
			change_state(State.JUMP)
	# ... existing movement logic
```

- [ ] **Step 2: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: implement wall jumping"
```

---

## Final Validation
- [ ] **Test Case 1: Wall Contact.** Jump against a wall. Player should play `wall-contact` then `wall-slide`.
- [ ] **Test Case 2: Wall Slide.** Ensure player slides down slower than normal gravity.
- [ ] **Test Case 3: Wall Jump.** Press jump while sliding. Player should launch diagonally away from the wall and play `wall-jump`.
- [ ] **Test Case 4: Wall Exit.** Move away from wall or land on floor. State should change accordingly.
