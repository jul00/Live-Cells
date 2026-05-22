# Combat Refinements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refine the player combat system to remove movement sliding, allow attack cancellation via movement, and fix the combo chain reliability for fast input.

**Architecture:**
- Modify `change_state()` to reset horizontal velocity when entering `State.ATTACK`.
- Update `_physics_process()` to detect movement input during attacks to trigger a state transition back to `State.MOVE`.
- Simplify `handle_combat_input()` to queue attacks without frame-based constraints.

**Tech Stack:** Godot 4.x (GDScript).

---

## File Map
- Modify: `scripts/player.gd`

---

## Task 1: Anti-Slide Implementation

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Update `change_state` to reset velocity**
Modify `change_state` to set `velocity.x = 0` when the new state is `State.ATTACK`.

```gdscript
func change_state(new_state: State, anim_name: String = ""):
	current_state = new_state
	if new_state == State.ATTACK:
		velocity.x = 0
	
	if anim_name != "":
		sprite.play(anim_name)
		return
	
	# ... (rest of match current_state)
```

- [ ] **Step 2: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: remove movement sliding during attacks"
```

---

## Task 2: Attack Interruption (Movement Cancel)

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Detect movement input during attacks**
In `_physics_process`, add a check to transition back to `State.MOVE` if movement is detected while attacking.

```gdscript
func _physics_process(delta: float) -> void:
	# ... (gravity and landing logic)
	
	if current_state == State.ATTACK:
		if Input.get_axis("ui_left", "ui_right") != 0:
			change_state(State.MOVE)
	
	if current_state == State.MOVE or current_state == State.JUMP:
		handle_movement_input()
	
	# ... (rest of physics process)
```

- [ ] **Step 2: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: allow movement to interrupt attacks"
```

---

## Task 3: Combo Chain Reliability (Spam Fix)

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Simplify `handle_combat_input`**
Remove the frame-based buffer check and simply set `next_attack_queued` to `true` on attack press.

```gdscript
func handle_combat_input():
	if Input.is_action_just_pressed("attack"):
		if current_state == State.ATTACK:
			next_attack_queued = true
		else:
			attack()
	# ... (special, dash, defend)
```

- [ ] **Step 2: Ensure `next_attack_queued` is reset on state change**
Update `change_state` to reset the buffer when switching away from `ATTACK` state.

- [ ] **Step 3: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: fix combo chain reliability for fast input"
```

---

## Final Validation
- [ ] **Test Case 1: Anti-Slide.** Start walking, press attack. Player should stop instantly.
- [ ] **Test Case 2: Movement Cancel.** Start attacking, press a movement key. Attack animation should stop and movement should begin.
- [ ] **Test Case 3: Combo Reliability.** Spam the attack button. Player should progress through `atk1` →
?→ `atk2` →
?→ `atk3` without sticking to `atk1`.
