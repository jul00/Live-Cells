# Safe Autoload Refactoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor scripts to use `get_node_or_null("/root/AutoloadName")` instead of direct global names for `AudioManager`, `LootManager`, and `GameManager`.

**Architecture:** Each script will perform a local lookup for the required Autoload and check for its validity before calling methods. This prevents runtime errors if the Autoload is missing.

**Tech Stack:** Godot GDScript.

---

### Task 1: Refactor `player.gd`

**Files:**
- Modify: `res://scripts/player.gd`

- [ ] **Step 1: Refactor footstep logic**

Replace direct `AudioManager` calls with safe lookups.

```gdscript
# Around L82
	if velocity.length() > 0 and is_on_floor():
		var am = get_node_or_null("/root/AudioManager")
		if am and not am.is_playing("footstep"):
			am.play_sfx("footstep")
	else:
		var am = get_node_or_null("/root/AudioManager")
		if am and am.is_playing("footstep"):
			am.stop_sfx("footstep")
```

- [ ] **Step 2: Refactor combat and movement logic**

Update other calls in `take_damage`, `dash`, etc.

```gdscript
# Around L143
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("block")

# Around L154
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("hit")
	var lm = get_node_or_null("/root/LootManager")
	if lm: lm.trigger_hit_stop(0.05)

# Around L221
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("hit")

# Around L253
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("dash")

# Around L282
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("hit")

# Around L292
	var gm = get_node_or_null("/root/GameManager")
	if gm: gm.game_over()
```

- [ ] **Step 3: Validate script**

Run: `mcp_godot_validate_script path="res://scripts/player.gd"`
Expected: PASS

### Task 2: Refactor Enemies (`grappler`, `rushdown`, `shoto`, `zoner`)

**Files:**
- Modify: `res://scripts/grappler_enemy.gd`, `res://scripts/rushdown_enemy.gd`, `res://scripts/shoto_enemy.gd`, `res://scripts/zoner_enemy.gd`

- [ ] **Step 1: Refactor `grappler_enemy.gd`**

```gdscript
# Around L118
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("hit")
```

- [ ] **Step 2: Refactor `rushdown_enemy.gd`**

```gdscript
# Around L293
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("block")
```

- [ ] **Step 3: Refactor `shoto_enemy.gd`**

```gdscript
# Around L141
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("dash")

# Around L385
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("block")
```

- [ ] **Step 4: Refactor `zoner_enemy.gd`**

```gdscript
# Around L132
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("dash")

# Around L258
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("bow_draw")

# Around L267
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("bow_shoot")
```

### Task 3: Refactor Boss and Items

**Files:**
- Modify: `res://scripts/boss.gd`, `res://scripts/health_item.gd`, `res://scripts/loot_manager.gd`

- [ ] **Step 1: Refactor `boss.gd`**

```gdscript
# Around L301
	var gm = get_node_or_null("/root/GameManager")
	if gm: gm.win_game()
```

- [ ] **Step 2: Refactor `health_item.gd`**

```gdscript
# Around L26
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("item_collect")
```

- [ ] **Step 3: Refactor `loot_manager.gd`**

```gdscript
# Around L39
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("item_spawn")
```

### Task 4: Refactor `ui.gd`

**Files:**
- Modify: `res://scripts/ui.gd`

- [ ] **Step 1: Refactor `_ready` and calls**

```gdscript
# Around L19
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.state_changed.connect(_on_game_state_changed)
		_on_game_state_changed(gm.current_state)

# Around L36
	var gm = get_node_or_null("/root/GameManager")
	if gm: gm.start_game()

# Around L40
	var gm = get_node_or_null("/root/GameManager")
	if gm: gm.restart_game()
```

- [ ] **Step 2: Refactor `_on_game_state_changed`**

Note: Enums are resolved via class name, so `GameManager.State` is usually safe if the script loads, but for consistency we use the local ref if we want to be truly paranoid about the instance. However, `new_state: GameManager.State` is a type hint.

### Task 5: Final Validation

- [ ] **Step 1: Run project**

Run the main scene and verify all gameplay systems work correctly.
