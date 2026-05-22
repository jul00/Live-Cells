# Enemy Loot System Design

**Date:** 2026-05-18
**Status:** Approved

## Goal
Implement a randomized loot drop system where enemies have a 20% chance to drop a health item (or a joke item) upon death.

## Architecture

### 1. LootManager (Autoload)
A global singleton that manages loot definitions and spawning logic.

- **Loot Table:**
    - `berry`: +10% HP
    - `apple`: +15% HP
    - `banana`: +20% HP
    - `steak`: +30% HP
    - `poo`: -20% HP (Joke item)
- **Function: `spawn_loot(position: Vector2)`**
    - Rolls a 20% chance.
    - On success:
        - Instances `res://scenes/health_items.tscn`.
        - Selects a random item from the table.
        - Assigns the corresponding sprite frame and heal value to the item instance.
        - Sets item position to `position`.

### 2. HealthItem Script
Attached to `res://scenes/health_items.tscn`.

- **Visuals:**
    - Implements a sine-wave bobbing effect in `_process` to make the item feel "alive".
    - `position.y = start_y + sin(time * speed) * amplitude`.
- **Interaction:**
    - Uses `Area2D` to detect the player.
    - On collection:
        - Applies the assigned heal/damage value to the player's health.
        - Calls `queue_free()`.

### 3. CombatEntity Integration
- **Base Class Update:** Add a `die()` method to `CombatEntity.gd`.
- **Death Logic:** `die()` calls `LootManager.spawn_loot(global_position)` before calling `queue_free()`.
- **Enemy Updates:** Update all enemy scripts (`boss.gd`, `grappler_enemy.gd`, `rushdown_enemy.gd`, `shoto_enemy.gd`, `zoner_enemy.gd`) to call `die()` instead of direct `queue_free()` when health reaches 0.

## Success Criteria
- Enemies randomly drop food/poo items upon death.
- Food items restore health; poo items reduce health.
- Items bob up and down visually.
- The system is centralized in `LootManager` for easy balancing.
