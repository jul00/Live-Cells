# Extended Stagger Duration (Frozen Recovery)

## Objective
Provide the player with a clearer opening by extending the time an enemy remains vulnerable after being hit.

## Core Mechanics

### 1. Frozen Recovery State
When a non-Juggernaut enemy (Shoto, Zoner) finishes its "hurt" animation, it will enter a brief "Frozen Recovery" period before it can act again.
- **Duration:** 0.5 seconds (adjustable via `@export`).
- **Implementation:** 
    - In `_on_animation_finished`, if the animation was "hurt", do NOT call `change_state(State.IDLE)` immediately.
    - Instead, keep the enemy in `State.HURT` (or a sub-state) and start a timer.
    - Once the timer expires, transition back to `State.IDLE`.

### 2. Vulnerability
During this frozen period:
- The enemy cannot move.
- The enemy cannot attack.
- The enemy can be hit again, resetting the stagger.

## Data Flow
1. **Animation Ends:** `_on_animation_finished` detects "hurt" animation completion.
2. **Delay Recovery:** `get_tree().create_timer(0.5).timeout` is used to create the window.
3. **Resume Action:** After timeout, `change_state(State.IDLE)` is finally called, allowing the AI to resume evaluation.

## Testing & Validation
- **Visual Check:** Confirm the Shoto/Zoner stays still for a moment after the "flinch" animation finishes.
- **Combat Flow:** Verify the player can land a follow-up hit during this window.
- **State Integrity:** Ensure the enemy eventually returns to its normal AI behavior.
