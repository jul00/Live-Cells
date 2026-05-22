# Grappler Juggernaut AI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the Grappler enemy into a "Juggernaut" that has Super Armor (no stagger) and flashes white when hit.

**Architecture:** 
- Override `receive_hit` in `grappler_enemy.gd` to prevent state changes to `HURT`.
- Implement a `play_hit_flash()` function using a `Tween` to modulate the sprite's color.
- Adjust `speed` and `roam_speed` constants to reflect a slower, more deliberate movement style.

**Tech Stack:** Godot GDScript

---

### Task 1: Implement Super Armor and Movement Speed

**Files:**
- Modify: `scripts/grappler_enemy.gd`

- [ ] **Step 1: Reduce walk speeds and override receive_hit**

```gdscript
# Around line 5
@export var speed: float = 40.0 # Reduced from 80.0
@export var roam_speed: float = 20.0 # Added/Adjusted

# Override receive_hit to implement Super Armor
func receive_hit(damage: float, attacker: Node2D) -> float:
	health -= damage
	print(name, " (Juggernaut) took hit! Health: ", health)
	play_hit_flash()
	# Note: We do NOT call change_state(State.HURT)
	return damage
```

- [ ] **Step 2: Add placeholder play_hit_flash function to avoid errors**

```gdscript
func play_hit_flash():
	pass
```

- [ ] **Step 3: Commit**

```bash
git add scripts/grappler_enemy.gd
git commit -m "feat(grappler): implement super armor and reduce movement speed"
```

---

### Task 2: Implement White Flash Visual Feedback

**Files:**
- Modify: `scripts/grappler_enemy.gd`

- [ ] **Step 1: Implement play_hit_flash using a Tween**

```gdscript
func play_hit_flash():
	if not sprite: return
	
	var tween = create_tween()
	# Flash to white (modulate = Color(10, 10, 10) for over-bright effect if using HDR, or just Color.WHITE)
	# We'll use a high value to make it look like a bright flash
	sprite.modulate = Color(5, 5, 5, 1) 
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
```

- [ ] **Step 2: Commit**

```bash
git add scripts/grappler_enemy.gd
git commit -m "feat(grappler): add white flash effect on hit"
```

---

### Task 3: Final Clean-up and Verification

**Files:**
- Modify: `scripts/grappler_enemy.gd`

- [ ] **Step 1: Remove any redundant code and verify State.HURT is no longer used for Grappler**

Check `_on_animation_finished` and other areas to ensure `State.HURT` doesn't cause issues if it's never entered.

- [ ] **Step 2: Verification**
- Run the game and attack the Grappler.
- Confirm it does not stagger.
- Confirm it flashes white.
- Confirm health still depletes.

- [ ] **Step 3: Commit**

```bash
git add scripts/grappler_enemy.gd
git commit -m "refactor(grappler): cleanup juggernaut implementation"
```
