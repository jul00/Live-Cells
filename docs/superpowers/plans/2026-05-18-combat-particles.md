# Combat Particles Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement procedural pixel-art style particle effects for combat hits and entity deaths.

**Architecture:** One-shot `CPUParticles2D` scenes triggered by the `CombatEntity` base class.

**Tech Stack:** Godot 4 (GDScript)

---

### Task 1: Hit Particles Scene

**Files:**
- Create: `scenes/fx/hit_particles.tscn`
- Create: `scripts/fx/one_shot_particles.gd`

- [ ] **Step 1: Create the particle script**
This script ensures the particle node deletes itself after finishing.
```gdscript
extends CPUParticles2D

func _ready():
	emitting = true
	finished.connect(queue_free)
```

- [ ] **Step 2: Create the HitParticles scene**
Configure `CPUParticles2D`:
- Amount: 10
- Lifetime: 0.3
- One Shot: true
- Explosiveness: 1.0
- Spread: 180
- Initial Velocity: 150
- Scale: 2.0 (pixel size)
- Color: Yellowish White

- [ ] **Step 3: Commit**
```bash
git add scenes/fx/hit_particles.tscn scripts/fx/one_shot_particles.gd
git commit -m "feat: add HitParticles scene and one-shot logic"
```

### Task 2: Death Particles Scene

**Files:**
- Create: `scenes/fx/death_particles.tscn`

- [ ] **Step 1: Create the DeathParticles scene**
Inherit from `CPUParticles2D` and use the `one_shot_particles.gd` script.
- Amount: 30
- Lifetime: 0.8
- One Shot: true
- Explosiveness: 0.9
- Direction: Vector2(0, -1)
- Spread: 45
- Gravity: Vector2(0, -50) (upward drift)
- Initial Velocity: 80
- Damping: 20
- Scale: 3.0
- Color Ramp: Fade from Grey to Transparent

- [ ] **Step 2: Commit**
```bash
git add scenes/fx/death_particles.tscn
git commit -m "feat: add DeathParticles scene"
```

### Task 3: CombatEntity Integration

**Files:**
- Modify: `scripts/combat_entity.gd`

- [ ] **Step 1: Preload scenes and add spawn method**
```gdscript
const HIT_FX = preload("res://scenes/fx/hit_particles.tscn")
const DEATH_FX = preload("res://scenes/fx/death_particles.tscn")

func spawn_particles(scene: PackedScene, pos: Vector2, color: Color = Color.WHITE):
	var fx = scene.instantiate()
	get_tree().root.add_child(fx)
	fx.global_position = pos
	fx.modulate = color
```

- [ ] **Step 2: Update `receive_hit`**
Trigger `HIT_FX` on every hit.

- [ ] **Step 3: Update `handle_death`**
Trigger `DEATH_FX` on death.

- [ ] **Step 4: Commit**
```bash
git add scripts/combat_entity.gd
git commit -m "feat: integrate particles into CombatEntity"
```

### Task 4: Player/Enemy Customization

**Files:**
- Modify: `scripts/player.gd`
- Modify: `scripts/shoto_enemy.gd` (and others if needed)

- [ ] **Step 1: Customize colors**
Ensure player hits show red sparks and enemies show white/yellow.

- [ ] **Step 2: Commit**
```bash
git add scripts/*.gd
git commit -m "feat: customize particle colors for player and enemies"
```
