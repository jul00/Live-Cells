# Combat Refinements Design
Date: 2026-05-12
Status: Proposed

## Overview
Refinements to the player's combat system to remove movement sliding during attacks, allow movement-based attack cancellation, and improve the reliability of the combo chain for fast input (spamming).

## 1. Movement Stopping (Anti-Slide)
To ensure a punchy feel and prevent the player from sliding across the floor while attacking.

### Logic
- When `change_state(State.ATTACK, ...)` is called, the player's horizontal velocity must be immediately reset: `velocity.x = 0`.
- This applies to:
    - Normal combo attacks (`atk1`, `atk2`, `atk3`).
    - Special attacks (`special-atk`).
    - Air attacks (`air-atk`) - optional, but recommended for consistent feel, though air friction is different.

## 2. Attack Interruption (Movement Cancel)
Allows the player to cancel an attack animation to move or dodge.

### Logic
- In `_physics_process`, the state machine currently only allows movement input in `MOVE` or `JUMP` states.
- **Change:** Add a check in `_physics_process` or `handle_combat_input` to detect movement input while in `State.ATTACK`.
- If `Input.get_axis("ui_left", "ui_right") != 0` and `current_state == State.ATTACK`:
    - Call `change_state(State.MOVE)`.
    - This immediately allows `handle_movement_input()` to take over and apply velocity.

## 3. Combo Chain Reliability (Spam Fix)
Replaces the frame-based buffer with a more forgiving input queue to ensure fast presses always progress the combo.

### Logic
- **Input Queuing:** When the `"attack"` action is pressed while `current_state == State.ATTACK`, `next_attack_queued` is set to `true` regardless of the current animation frame.
- **Execution:** In `_on_animation_finished()`, if `next_attack_queued` is true, the next attack in the sequence is triggered.
- **Reset:** `next_attack_queued` is reset to `false` when:
    - A new attack is successfully triggered.
    - The state changes to something other than `ATTACK` (e.g., the movement cancel).
    - (Optional) A short timer expires (e.g., 0.5s).

## 4. Technical Impact
- **Modify:** `scripts/player.gd`
- **Key functions to update:**
    - `change_state()`: To handle the `velocity.x = 0` reset.
    - `_physics_process()`: To check for movement cancels.
    - `handle_combat_input()`: To simplify the buffering logic.
    - `_on_animation_finished()`: To handle the queued attack execution.
