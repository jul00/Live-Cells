# Shoto and Zoner Hurt State Fix

## Objective
Ensure Shoto and Zoner enemies correctly react to damage by entering a stagger state and canceling any active attacks.

## Core Mechanics

### 1. Consistent Damage & Stagger
Override `receive_hit` in both `shoto_enemy.gd` and `zoner_enemy.gd`.
- **Implementation:** 
    - Call `super.receive_hit(damage, attacker)` to ensure health is deducted and the hit is printed.
    - Call `change_state(State.HURT)` immediately.
- **Goal:** Standardize how non-Juggernaut enemies handle incoming damage.

### 2. Attack Interruption
When an enemy enters the `HURT` state, any active attack must be neutralized.
- **Implementation:** In the `change_state` function's `HURT` entry logic:
    - Call `activate_hitbox("", false)` to disable the `AttackArea`.
- **Goal:** Prevent "trade-hits" where an enemy continues to damage the player while being staggered.

### 3. Visual Feedback
- **Animation:** Trigger the "hurt" animation when entering the state.
- **Recovery:** In `_on_animation_finished`, when the "hurt" animation ends, return the enemy to `State.IDLE`.

## Data Flow
1. **Hit Registered:** Player's `AttackArea` hits Enemy's `Hurtbox`.
2. **Process Hit:** Enemy's `receive_hit` deducts health and calls `change_state(State.HURT)`.
3. **Interrupt:** `change_state` disables hitboxes and plays "hurt" animation.
4. **Recover:** Animation ends, enemy returns to `IDLE` to re-evaluate combat.

## Testing & Validation
- **Stagger:** Attack a Shoto/Zoner and confirm they stop moving/attacking and play the "hurt" animation.
- **Health:** Confirm their health decreases (viewable in console logs).
- **Interruption:** Verify that if you hit an enemy while they are in the middle of an attack, their hitbox is disabled and you don't take damage from that specific attack.
