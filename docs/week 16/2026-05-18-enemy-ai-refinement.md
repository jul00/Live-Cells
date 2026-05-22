# Enemy AI Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve idle behaviors for all standard enemies and enhance Zoner distancing logic.

**Architecture:** Shared visual helper in `CombatEntity` for the "Look Around" behavior, and specific state-machine logic updates for the Zoner's tactical movement.

**Tech Stack:** Godot 4 (GDScript)

---

### Task 1: Shared Visual Helper

**Files:**
- Modify: `scripts/combat_entity.gd`

- [ ] **Step 1: Add `perform_look_around` helper**
This method handles the timer-based flipping logic without blocking the rest of the script.

```gdscript
func perform_look_around():
	if not sprite: return
	
	# Initial pause
	await get_tree().create_timer(0.5).timeout
	if is_dead: return
	
	# Flip look
	sprite.flip_h = !sprite.flip_h
	update_combat_facing()
	
	# Pause while looking away
	await get_tree().create_timer(0.8).timeout
	if is_dead: return
	
	# Flip back
	sprite.flip_h = !sprite.flip_h
	update_combat_facing()
```

- [ ] **Step 2: Commit**
```bash
git add scripts/combat_entity.gd
git commit -m "feat: add perform_look_around helper to CombatEntity"
```

### Task 2: Idle Refinement (Standard Enemies)

**Files:**
- Modify: `scripts/shoto_enemy.gd`
- Modify: `scripts/rushdown_enemy.gd`
- Modify: `scripts/grappler_enemy.gd`

- [ ] **Step 1: Implement roll in `change_state`**
In the `match new_state:` block for `State.IDLE`, add the 40% roll.

```gdscript
State.IDLE:
	velocity.x = 0
	if randf() < 0.4:
		perform_look_around()
```

- [ ] **Step 2: Commit**
```bash
git add scripts/shoto_enemy.gd scripts/rushdown_enemy.gd scripts/grappler_enemy.gd
git commit -m "feat: implement look-around behavior for standard enemies"
```

### Task 3: Zoner Tactical Distancing

**Files:**
- Modify: `scripts/zoner_enemy.gd`

- [ ] **Step 1: Implement Proactive Evasion**
Update `evaluate_combat_state()` to enter `State.EVADE` if the player is too close.

```gdscript
if dist < danger_zone_dist:
	change_state(State.EVADE) # Proactive dash away
```

- [ ] **Step 2: Update Spacing Speed**
In `process_spacing()`, change `roam_speed` to `speed`.

```gdscript
# While spacing and waiting for cooldown, back-pedal at full speed
var dir_to_player = (target_player.global_position - global_position).normalized()
velocity.x = -dir_to_player.x * speed 
```

- [ ] **Step 3: Implement Look Around for Zoner**
Add the roll to `State.IDLE` entry in `change_state()`.

- [ ] **Step 4: Commit**
```bash
git add scripts/zoner_enemy.gd
git commit -m "feat: enhance Zoner tactical distancing and idle logic"
```
