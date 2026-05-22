# Boss AI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a 2-phase boss with blocking, knockbacks, and an empowered flaming sword phase.

**Architecture:** 
- `boss.gd` inherits from `CombatEntity`.
- Uses a `is_phase_2` boolean to handle animation suffixes and damage multipliers.
- Implements a `SHOUT` state for the cinematic transition at 50% health.
- Uses `Area2D` signals for player detection and combat range.

**Tech Stack:** Godot GDScript

---

### Task 1: Setup Boss Scene Nodes

**Files:**
- Modify: `res://scenes/boss.tscn`

- [ ] **Step 1: Add necessary Area2D nodes**
Add the following nodes to the root `Boss` node:
1. `DetectionArea` (Area2D) + `CollisionShape2D` (RectangleShape2D, large range)
2. `AttackArea` (Area2D) + `CollisionShape2D` (RectangleShape2D, melee range)
3. `Hurtbox` (Area2D) + `CollisionShape2D` (CapsuleShape2D, matches body)
4. `RayCast2D` (For ledge safety)

- [ ] **Step 2: Set strict Area2D properties**
- `AttackArea`: `monitoring=false`, `monitorable=false`
- `Hurtbox`: `monitoring=false`, `monitorable=true`

- [ ] **Step 3: Connect Signals**
Connect `area_entered` from `AttackArea` to `_on_attack_area_area_entered` (inherited from base).
Connect `body_entered` and `body_exited` from `DetectionArea` to script methods.

---

### Task 2: Implement Boss AI Script (Phase 1 & Transition)

**Files:**
- Create: `scripts/boss.gd`

- [ ] **Step 1: Implement base state machine and health trigger**

```gdscript
extends CombatEntity

enum State { IDLE, ROAM, APPROACH, COMBAT, DEFEND, SHOUT, HURT, DEATH }

@export var max_health: float = 200.0
@export var phase_2_speed_mult: float = 1.4

var current_state = State.IDLE
var is_phase_2 = false
var target_player: CharacterBody2D = null

func _ready():
    super._ready()
    health = max_health
    hitbox_profiles = {
        "atk1": {"pos": Vector2(30, -20), "size": Vector2(60, 50), "damage": 15.0},
        "atk2": {"pos": Vector2(30, -20), "size": Vector2(60, 50), "damage": 15.0},
        "atk3": {"pos": Vector2(35, -25), "size": Vector2(80, 60), "damage": 25.0}
    }
    sprite.animation_finished.connect(_on_animation_finished)

func receive_hit(damage: float, attacker: Node2D) -> float:
    var final_damage = damage
    if current_state == State.DEFEND:
        _apply_block_knockback(attacker)
        final_damage *= 0.1 # 90% reduction
    
    super.receive_hit(final_damage, attacker)
    
    if not is_phase_2 and health <= max_health * 0.5:
        change_state(State.SHOUT)
    elif current_state != State.DEFEND:
        change_state(State.HURT)
        
    return final_damage
```

- [ ] **Step 2: Implement the Shout and Animation Suffix logic**

```gdscript
func get_anim(anim_name: String) -> String:
    return anim_name + "(flame)" if is_phase_2 else anim_name

func change_state(new_state: State):
    # ... standard entry/exit logic ...
    match current_state:
        State.SHOUT:
            sprite.play("shout")
            _trigger_mass_knockback()
```

---

### Task 3: Implement Phase 2 Mechanics

**Files:**
- Modify: `scripts/boss.gd`

- [ ] **Step 1: Add Heavy Lunges and Double Damage in Phase 2**

```gdscript
func _start_attack(anim_name: String):
    var damage_mult = 2.0 if is_phase_2 else 1.0
    # Override hitbox activation to apply multiplier
    # ...
    
    if is_phase_2:
        # Grappler-style lunge
        var dir = 1 if not sprite.flip_h else -1
        velocity.x = dir * 400.0 
```

- [ ] **Step 2: Commit and Final Verification**

```bash
git add scripts/boss.gd res://scenes/boss.tscn
git commit -m "feat(boss): implement 2-phase AI with flaming sword transition"
```
