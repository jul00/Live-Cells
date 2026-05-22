# Dynamic Particle Effects Design

**Date:** 2026-05-18
**Status:** Approved

## Goal
Implement procedural pixel-art style particle effects for combat hits and entity deaths to increase visual feedback and "juice".

## Architecture

### 1. Particle Scenes
Two reusable scenes will be created using `CPUParticles2D` for performance and simplicity.

#### `HitParticles` (`res://scenes/fx/hit_particles.tscn`)
- **Type:** One-shot burst.
- **Visuals:** 
    - 8-12 square particles (2x2 pixels).
    - Initial velocity: High spread (360 degrees).
    - Gravity: Low downward pull.
    - Lifetime: 0.3s.
- **Purpose:** Provide immediate feedback on hit connection.

#### `DeathParticles` (`res://scenes/fx/death_particles.tscn`)
- **Type:** One-shot burst.
- **Visuals:**
    - 25-30 square particles (3x3 pixels).
    - Initial velocity: Moderate upward spread.
    - Gravity: Negative (particles drift upward like smoke).
    - Damping: High (slows down over time).
    - Lifetime: 0.8s.
    - Color Ramp: Fades to transparent.
- **Purpose:** Visual "poof" when an entity is removed from the game.

### 2. Integration Logic
- **CombatEntity.gd:**
    - Add a function to spawn these particles.
    - `receive_hit()`: Trigger `HitParticles` at the impact location.
    - `handle_death()`: Trigger `DeathParticles` at the entity's center.

## Success Criteria
- Hits feel more impactful with visible "sparks".
- Deaths are accompanied by a smoke-like "poof" effect.
- The effects match the pixel art aesthetic (square, non-aliased particles).
