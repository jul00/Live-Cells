# Grappler AI Improvement: The Juggernaut

## Objective
Transform the Grappler enemy into a "Juggernaut" archetype: a slow, relentless threat that cannot be staggered by player attacks.

## Core Mechanics

### 1. Super Armor (Passive)
The Grappler will no longer enter a "HURT" or "stagger" state when taking damage.
- **Implementation:** Override `receive_hit` in `grappler_enemy.gd`.
- **Behavior:** Subtract health normally, but do NOT call `change_state(State.HURT)`. The enemy continues its current action (approaching or attacking) without interruption.

### 2. Relentless Movement
- **Walk Speed:** Reduce base speed to make the approach feel more like a slow, looming threat.
- **Approach Logic:** The Grappler will constantly march toward the player whenever they are in range.

### 3. Burst Slide Attack
- The existing slide attack remains the primary method for the Grappler to close the final gap and deal heavy damage.
- Because of Super Armor, the Grappler will likely finish every attack it starts, forcing the player to dodge rather than counter-hit.

## Visual Feedback: The White Flash
Since the "HURT" animation is removed, players need a new visual cue to know their hits are landing.
- **Effect:** Whenever the Grappler takes damage, its sprite will flash solid white for 0.1 seconds.
- **Implementation:** 
    - Use a simple script-based `modulate` or a `ShaderMaterial` (if available/preferred) to toggle the color.
    - A `Tween` or `get_tree().create_timer()` will be used to handle the flash duration and reset it to normal.

## Data Flow
1. **Hit Registered:** `_on_attack_area_area_entered` (Attacker) triggers `receive_hit` (Grappler).
2. **Process Hit:** `receive_hit` updates health and triggers `play_flash_effect()`.
3. **Continue Action:** The Grappler's current `_physics_process` state (e.g., `APPROACH`) continues uninterrupted.

## Testing & Validation
- **No Stagger:** Verify that the Grappler does not stop walking or attacking when the player hits it.
- **Visual Feedback:** Verify that every player hit triggers a distinct white flash on the Grappler's sprite.
- **Health Update:** Ensure damage is still being subtracted correctly even without the stagger.
