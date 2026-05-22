# Enemy Loot System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a randomized loot drop system where enemies have a 20% chance to drop a health item (or a joke item) upon death.

**Architecture:** Centralized loot management via a `LootManager` autoload. `CombatEntity` handles the death trigger, and a new `HealthItem` script manages the visual bobbing and player interaction.

**Tech Stack:** Godot 4 (GDScript)

---

### Task 1: Player Healing Logic

**Files:**
- Modify: `scripts/player.gd`

- [ ] **Step 1: Add `heal` method to `Player`**

```gdscript
func heal(amount: float):
	# amount can be positive (healing) or negative (damage/poo)
	health += amount
	health = clamp(health, 0, 100.0)
	print("Player healed by ", amount, ". Current health: ", health)
	
	if health <= 0:
		change_state(State.DEATH)
```

- [ ] **Step 2: Commit**

```bash
git add scripts/player.gd
git commit -m "feat: add heal method to player"
```

### Task 2: Loot Manager Singleton

**Files:**
- Create: `scripts/loot_manager.gd`

- [ ] **Step 1: Implement `LootManager` logic**

```gdscript
extends Node

const HEALTH_ITEM_SCENE = preload("res://scenes/health_items.tscn")

# Map of item names to their heal value (as % of max health)
# Indices correspond to the AnimatedSprite2D frames in health_items.tscn
var loot_table = {
	"berry": {"frame": 0, "value": 10.0},
	"apple": {"frame": 1, "value": 15.0},
	"banana": {"frame": 2, "value": 20.0},
	"steak": {"frame": 3, "value": 30.0},
	"poo": {"frame": 4, "value": -20.0}
}

func spawn_loot(pos: Vector2):
	if randf() > 0.2:
		return # 20% drop chance
	
	var item = HEALTH_ITEM_SCENE.instantiate()
	add_child(item)
	item.global_position = pos
	
	# Pick a random item from the table
	var item_keys = loot_table.keys()
	var random_key = item_keys[randi() % item_keys.size()]
	var data = loot_table[random_key]
	
	# Set properties on the item
	if item.has_method("setup"):
		item.setup(data["frame"], data["value"])
	else:
		push_error("HealthItem missing setup method!")

```

- [ ] **Step 2: Register as Autoload**
The user must add `scripts/loot_manager.gd` to the Autoload list in Project Settings as `LootManager`.

- [ ] **Step 3: Commit**

```bash
git add scripts/loot_manager.gd
git commit -m "feat: implement LootManager singleton"
```

### Task 3: Health Item Script

**Files:**
- Create: `scripts/health_item.gd`
- Modify: `scenes/health_items.tscn` (to attach the script)

- [ ] **Step 1: Implement `HealthItem` logic**

```gdscript
extends CharacterBody2D

var heal_amount: float = 0.0
var start_y: float = 0.0

@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D

var bob_speed = 2.0
var bob_amplitude = 5.0

func _ready():
	start_y = position.y
	area.area_entered.connect(_on_area_entered)
	area.body_entered.connect(_on_body_entered)

func setup(frame: int, value: float):
	heal_amount = value
	sprite.frame = frame

func _process(delta):
	# Sine wave bobbing
	position.y = start_y + sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amplitude

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("heal"):
		body.heal(heal_amount)
		queue_free()

func _on_area_entered(_area):
	pass # Not used but kept for completeness
```

- [ ] **Step 2: Attach script to scene**
Use `mcp_godot_attach_script` to attach `res://scripts/health_item.gd` to `res://scenes/health_items.tscn`.

- [ ] **Step 3: Commit**

```bash
git add scripts/health_item.gd
git commit -m "feat: implement HealthItem bobbing and collection"
```

### Task 4: CombatEntity Base Class Update

**Files:**
- Modify: `scripts/combat_entity.gd`

- [ ] **Step 1: Add `die` method**

```gdscript
func die():
	if LootManager:
		LootManager.spawn_loot(global_position)
	queue_free()
```

- [ ] **Step 2: Commit**

```bash
git add scripts/combat_entity.gd
git commit -m "feat: add die method to CombatEntity"
```

### Task 5: Enemy Script Integration

**Files:**
- Modify: `scripts/boss.gd`
- Modify: `scripts/grappler_enemy.gd`
- Modify: `scripts/rushdown_enemy.gd`
- Modify: `scripts/shoto_enemy.gd`
- Modify: `scripts/zoner_enemy.gd`

- [ ] **Step 1: Replace `queue_free()` with `die()` in death checks**
For each file, find the `if health <= 0:` block and replace the subsequent `queue_free()` with `die()`.

- [ ] **Step 2: Commit**

```bash
git add scripts/boss.gd scripts/grappler_enemy.gd scripts/rushdown_enemy.gd scripts/shoto_enemy.gd scripts/zoner_enemy.gd
git commit -m "feat: integrate enemy death with loot system"
```
