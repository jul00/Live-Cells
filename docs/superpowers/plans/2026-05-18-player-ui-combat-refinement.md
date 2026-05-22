# Player UI and Combat Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a visual health bar for the player, enable enemy-to-player damage, and refine the loot spawn timing and visual behavior.

**Architecture:** A new `UI` scene for the health bar, updated player health logic with death pause, and recalibrated enemy damage profiles.

**Tech Stack:** Godot 4 (GDScript)

---

### Task 1: UI Health Bar Scene

**Files:**
- Create: `scenes/ui.tscn`

- [ ] **Step 1: Create the UI scene**
Construct a `CanvasLayer` root with a `ProgressBar` child.
```gdscript
# (This is the .tscn structure)
[node name="UI" type="CanvasLayer"]
process_mode = 3 # Always process (so it doesn't pause with the game)

[node name="HealthBar" type="ProgressBar" parent="."]
offset_left = 20.0
offset_top = 20.0
offset_right = 220.0
offset_bottom = 47.0
max_value = 800.0
value = 800.0
show_percentage = true
theme_override_styles/fill = SubResource("StyleBoxFlat_green")
```

- [ ] **Step 2: Add to groups**
The `HealthBar` node should be added to the group `"ui_health_bar"`.

- [ ] **Step 3: Commit**
```bash
git add scenes/ui.tscn
git commit -m "feat: add player health bar UI scene"
```

### Task 2: Player Health & Death Logic

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Update health stats and UI sync**
Set `health = 800.0` in `_ready`.
Implement a helper to find and update the UI health bar.

```gdscript
func update_health_ui():
	var bars = get_tree().get_nodes_in_group("ui_health_bar")
	for bar in bars:
		if bar is ProgressBar:
			bar.value = health
```

- [ ] **Step 2: Update `receive_hit` and `heal`**
Call `update_health_ui()` after health changes.

- [ ] **Step 3: Implement Death Pause**
In `_on_animation_finished`, if the animation is `death`, call `get_tree().paused = true`.

- [ ] **Step 4: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: implement 800 HP, UI sync, and death pause"
```

### Task 3: Enemy Damage Balancing

**Files:**
- Modify: `scripts/shoto_enemy.gd`
- Modify: `scripts/rushdown_enemy.gd`
- Modify: `scripts/zoner_enemy.gd`
- Modify: `scripts/grappler_enemy.gd`
- Modify: `scripts/boss.gd`
- Modify: `scripts/loot_manager.gd`

- [ ] **Step 1: Update Enemy Damage**
  - Shoto: `damage = 40.0`
  - Rushdown: `damage = 60.0`
  - Zoner (Arrow): `damage = 40.0`
  - Grappler: `damage = 120.0`
  - Boss: Phase 1 `damage = 80.0`, Phase 2 (multiplied) `damage = 160.0`

- [ ] **Step 2: Update Loot Table (Poo)**
  - Change Poo damage to `-160.0`.

- [ ] **Step 3: Commit**
```bash
git add scripts/*.gd
git commit -m "feat: balance enemy and boss damage"
```

### Task 4: Health Item Visual Fix

**Files:**
- Modify: `scripts/health_item.gd`

- [ ] **Step 1: Fix bobbing logic**
Change the target of the sine wave from the root `position.y` to the `sprite.position.y`.

```gdscript
func _process(_delta: float) -> void:
	if sprite:
		sprite.position.y = -12 + sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amplitude
```
*(Assuming -12 is the base offset for the sprite).*

- [ ] **Step 2: Commit**
```bash
git add scripts/health_item.gd
git commit -m "fix: move sprite only for bobbing to prevent physics glitch"
```

### Task 5: Final Level Integration

**Files:**
- Modify: `scenes/boss_level.tscn` (or your main testing scene)

- [ ] **Step 1: Instance UI**
Add `res://scenes/ui.tscn` to your main gameplay scene(s) so the health bar appears.

- [ ] **Step 2: Commit**
```bash
git add scenes/boss_level.tscn
git commit -m "feat: integrate UI into level"
```
