# Boss AI: The 2-Phase Flaming Demon Samurai

## Objective
Create a challenging 2-phase boss encounter featuring defensive counters, a cinematic transition, and an empowered flaming sword phase.

## Core Mechanics

### 1. Defensive Counter (All Phases)
- **State:** `DEFEND`
- **Activation:** High chance to block when the player is close and attacking.
- **Counter Effect:** If the boss takes a hit while defending:
    - Block animation plays.
    - **Knockback:** A radial burst triggers, pushing the player away.
    - **Retaliation:** In Phase 2, the boss immediately follows up with a flaming strike.

### 2. The Great Shout (Phase Transition)
- **Trigger:** Health reaches **50%**.
- **Animation:** `shout` (Looping/Timed).
- **Effect:** Triggers a large-scale knockback area that clears the space around the boss.
- **Transformation:** Sets `is_phase_2 = true`. All subsequent animations will use the `(FLAMING SWORD)` variant.

### 3. Phase 2: The Flaming Demon
- **Damage:** All attacks deal **2x damage**.
- **Heavy Lunges:** All melee attacks (`atk1`, `atk2`, `atk3`) now include a forward velocity dash (similar to the Grappler) during the active frames to ensure the boss stays on the offensive.
- **Speed:** Increased base movement speed.

## Animation Mapping
The script will dynamically suffix animation names:
- Phase 1: `anim_name`
- Phase 2: `anim_name + "(flame)"` (matching the `SpriteFrames` names).

## Data Flow
1. **Hit Received:** `receive_hit` checks if current HP < 50% max and `!is_phase_2`.
2. **Phase Change:** If threshold met, `change_state(State.SHOUT)`.
3. **Transition Cleanup:** Shout ends -> `is_phase_2 = true` -> Resume combat with flaming sword.

## Testing & Validation
- **Block Mechanic:** Verify the player is pushed back when hitting the boss's guard.
- **HP Trigger:** Verify the shout triggers exactly at 50% health.
- **Phase 2 Buffs:** Confirm attacks do double damage and the boss lunges forward.
- **Animation Sync:** Ensure `(FLAMING SWORD)` animations play correctly in Phase 2.
