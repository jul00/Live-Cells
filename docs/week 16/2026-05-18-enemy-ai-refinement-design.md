# Enemy AI Refinement Design

**Date:** 2026-05-18
**Status:** Approved

## Goal
Improve the "life-like" quality of all standard enemies through advanced idle behaviors and significantly enhance the Zoner's ability to maintain a tactical distance.

## Architecture

### 1. Idle "Look Around" Behavior
Applies to: Shoto, Rushdown, Zoner, and Grappler.

- **Trigger:** Upon entering the `IDLE` state, a random roll determines if the enemy "looks around".
- **Logic:**
    - Roll Chance: 40%.
    - Delay: 0.5s initial pause.
    - Action: Flip `sprite.flip_h` to face the opposite direction.
    - Duration: 0.8s pause while facing the "wrong" way.
    - Recovery: Flip back to the original direction before transitioning to `ROAM`.

### 2. Zoner Tactical Distancing
Specifically for `scripts/zoner_enemy.gd`.

- **Proactive Evasion:**
    - If the player distance < `danger_zone_dist`, the Zoner immediately enters the `EVADE` state (dashing away) to reset the gap.
- **Aggressive Back-pedaling:**
    - While in `SPACING` (cooldown), the Zoner will move at `speed` (full walk speed) instead of `roam_speed` when moving away from the player.
- **Reactive Defense (Retained):**
    - The existing "Stagger Breaker" (HP-based dash) remains as a failsafe when the Zoner actually takes damage.

## Success Criteria
- Enemies look more active and aware while patrolling.
- The Zoner is much harder to corner, consistently resetting the distance using dashes.
- The Zoner's movement feels decisive and tactical rather than passive.
