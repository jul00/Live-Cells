# Player UI and Combat Refinement Design

**Date:** 2026-05-18
**Status:** Approved

## Goal
Implement a visual health bar for the player, enable enemy-to-player damage, and refine the loot spawn timing and visual behavior.

## Architecture

### 1. UI Health Bar (`res://scenes/ui.tscn`)
- **Root:** `CanvasLayer` (layer 100 to ensure it's always on top).
- **ProgressBar:**
    - Name: `PlayerHealthBar`.
    - Position: Top-left (offset roughly 20, 20).
    - Size: ~200x20 pixels.
    - Colors: Green fill (`bg_color` dark gray, `fg_color` green).
    - Range: `min_value = 0`, `max_value = 800`.
    - Value: Displays as a percentage or current/max health.

### 2. Player Combat Refinement (`scripts/player.gd`)
- **Health:** Set base health to `800.0`.
- **Death Logic:**
    - Triggered when `health <= 0`.
    - Play `death` animation.
    - In `_on_animation_finished`, if animation was `death`, set `get_tree().paused = true`.
- **UI Synchronization:** 
    - The player will look for the `PlayerHealthBar` in a specific group (e.g., "ui_health_bar") and update its `value` whenever `health` changes.

### 3. Enemy Damage Balancing
Adjust the `hitbox_profiles` in each enemy script:
- **Shoto Enemy:** `damage = 40.0`
- **Rushdown Enemy:** `damage = 60.0`
- **Zoner (Arrow):** `damage = 40.0`
- **Grappler Enemy:** `damage = 120.0`
- **Loot Table (Poo):** Updated to `-160.0` (exactly 20% of 800).

### 4. Item Visual & Timing Fixes
- **HealthItem Script (`scripts/health_item.gd`):**
    - Modify the bobbing logic to only update the `AnimatedSprite2D.position.y` instead of the entire `Area2D.position.y`. This prevents physics glitches with platforms.
- **CombatEntity Script (`scripts/combat_entity.gd`):**
    - Ensure `handle_death` uses a `0.8s` timer for loot spawning.

## Success Criteria
- A green health bar appears in the top-left and updates in real-time.
- Enemies can damage the player.
- Player death triggers the animation and pauses the entire game.
- Health items bob smoothly without snapping or glitching through floors.
- Loot spawns with the correct 0.8s delay after death animations.
