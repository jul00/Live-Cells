# DeathParticles Scene Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a reusable "poof" particle effect for character deaths.

**Architecture:** Create a `CPUParticles2D` scene that acts as a one-shot effect, disappearing after the animation finishes.

**Tech Stack:** Godot 4 (GDScript + .tscn)

**Date:** April 2026 (Week 12)

---

### Task 1: Create and Configure DeathParticles Scene

**Files:**
- Create: `scenes/fx/death_particles.tscn`

- [ ] **Step 1: Create the scene file**
Create `scenes/fx/death_particles.tscn` with a `CPUParticles2D` root node and attach `res://scripts/fx/one_shot_particles.gd`.

- [ ] **Step 2: Configure particle properties**
Set the following properties on the `DeathParticles` node:
- `amount`: 30
- `lifetime`: 0.8
- `one_shot`: true
- `explosiveness`: 0.9
- `direction`: Vector2(0, -1)
- `spread`: 45.0
- `gravity`: Vector2(0, -50.0)
- `initial_velocity_min`: 50.0
- `initial_velocity_max`: 80.0
- `damping_min`: 20.0
- `damping_max`: 20.0
- `scale_amount_min`: 3.0
- `scale_amount_max`: 3.0

- [ ] **Step 3: Configure color ramp**
Create a `Gradient` resource for the `color_ramp` property:
- Point 0: Color(0.5, 0.5, 0.5, 1.0) at offset 0.0
- Point 1: Color(0.5, 0.5, 0.5, 0.0) at offset 1.0

- [ ] **Step 4: Verify the scene**
Run the scene to ensure particles emit and the node is freed.

- [ ] **Step 5: Commit**
```bash
git add scenes/fx/death_particles.tscn
git commit -m "feat: add DeathParticles scene"
```
