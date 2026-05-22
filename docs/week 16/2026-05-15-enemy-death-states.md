# Enemy Death States: Immediate Dissolve

## Objective
Implement a consistent death behavior for all remaining enemies (Shoto, Zoner, Grappler) that ensures proper cleanup and visual feedback.

## Core Mechanics

### 1. Death Trigger
- **Condition:** Health reaches 0.0 or below in the `receive_hit` function.
- **Action:** Transition to `State.DEATH`.

### 2. Death State Logic
Upon entering `State.DEATH`:
- **Movement:** Stop all horizontal movement (`velocity.x = 0`).
- **Combat:** Disable the `AttackArea` (`activate_hitbox("", false)`).
- **Collision:** Disable the `Hurtbox` and optionally the main collision shape to prevent dead enemies from blocking the player or other projectiles.
- **Visuals:** Play the "die" animation.

### 3. Cleanup
- **Trigger:** The `animation_finished` signal.
- **Action:** If the finished animation is "die", call `queue_free()` to remove the enemy from the scene.

## Implementation Details

### State Machine Updates
- Add `DEATH` to the `State` enum in `shoto_enemy.gd`, `zoner_enemy.gd`, and `grappler_enemy.gd`.
- Update `change_state` to handle the `DEATH` entry logic.
- Update `_on_animation_finished` to handle node removal.

### Animation Safety
- Ensure the `die` animation is set to **non-looping** in the `.tscn` files (previously fixed for Shoto, but need to verify for others).

## Data Flow
1. **Fatal Hit:** `receive_hit` detects health <= 0.
2. **Transition:** `change_state(State.DEATH)` is called.
3. **Deactivate:** AI stops, collisions turn off, "die" plays.
4. **Dissolve:** Animation ends -> `queue_free()`.

## Testing & Validation
- **Animation Check:** Verify that the "die" animation plays to completion.
- **Cleanup Check:** Confirm the enemy node is removed from the Scene Tree after death.
- **Collision Check:** Ensure the player can walk through a dying enemy.
