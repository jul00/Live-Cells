# Audio System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a centralized, randomized, and dynamic audio system.

**Architecture:** A singleton `AudioManager` that manages sound libraries and a pool of audio players.

**Tech Stack:** Godot 4 (GDScript)

---

### Task 1: AudioManager Singleton

**Files:**
- Create: `scripts/audio_manager.gd`

- [ ] **Step 1: Implement the AudioManager logic**
Define libraries for `hit`, `block`, `dash`, `item_spawn`, and `item_collect`.
Implement a pool of 16 `AudioStreamPlayer` nodes.

```gdscript
extends Node

var libs = {
	"hit": [
		preload("res://assets/SFX/cut1.mp3"),
		preload("res://assets/SFX/cut2.mp3"),
		preload("res://assets/SFX/cut3.mp3")
	],
	"block": [
		preload("res://assets/SFX/block1.mp3"),
		preload("res://assets/SFX/block2.mp3"),
		preload("res://assets/SFX/block3.mp3"),
		preload("res://assets/SFX/block4.mp3")
	],
	"dash": [preload("res://assets/SFX/dash.mp3")],
	"item_spawn": [preload("res://assets/SFX/item_drop.wav")],
	"item_collect": [preload("res://assets/SFX/item_pickup.wav")]
}

var players: Array[AudioStreamPlayer] = []

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	for i in range(16):
		var p = AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

func play_sfx(lib_name: String, p_min: float = 0.9, p_max: float = 1.1):
	if not libs.has(lib_name): return
	
	var stream = libs[lib_name].pick_random()
	for p in players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = randf_range(p_min, p_max)
			p.play()
			break
```

- [ ] **Step 2: Commit**
```bash
git add scripts/audio_manager.gd
git commit -m "feat: implement AudioManager with sound pool and randomization"
```

### Task 2: Combat Audio Integration (Player)

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Trigger hit sound**
In `attack()`, add the `AudioManager.play_sfx("hit")` call.

- [ ] **Step 2: Trigger block sound**
In `receive_hit()`, when in `State.DEFEND`, call `AudioManager.play_sfx("block")`.

- [ ] **Step 3: Trigger dash sound**
In `handle_combat_input()`, when dashing, call `AudioManager.play_sfx("dash")`.

- [ ] **Step 4: Commit**
```bash
git add scripts/player.gd
git commit -m "feat: integrate SFX into player combat actions"
```

### Task 3: Item Audio Integration

**Files:**
- Modify: `scripts/loot_manager.gd`
- Modify: `scripts/health_item.gd`

- [ ] **Step 1: Trigger item spawn**
In `spawn_loot()`, call `AudioManager.play_sfx("item_spawn")`.

- [ ] **Step 2: Trigger item collect**
In `_on_body_entered()`, call `AudioManager.play_sfx("item_collect")`.

- [ ] **Step 3: Commit**
```bash
git add scripts/loot_manager.gd scripts/health_item.gd
git commit -m "feat: integrate SFX into loot system"
```
