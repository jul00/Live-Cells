# Archer Zoner Enemy Design Spec
Date: 2026-05-13
Topic: Zoner Archetype Implementation

## 1. Overview
The Archer is a zoner archetype enemy designed to maintain a specific distance from the player, using a combination of reactive back-pedaling and strategic retreats. It uses a priority-based behavior system rather than a rigid state machine to ensure fluid movement and decision-making.

## 2. Architecture: Behavior Tree Lite
The Archer evaluates its actions every physics frame based on a priority list. The first condition that evaluates to `true` is executed.

### Priority Evaluation Loop (High to Low)
1. **Survival (Danger Zone):** 
   - **Condition:** Player distance < `danger_zone_dist`.
   - **Action:** Immediate retreat (move away from player). Cancel pending attacks.
2. **Spacing (Engagement Zone):** 
   - **Condition:** `danger_zone_dist` < Player distance < `engagement_zone_dist`.
   - **Action:** Back-pedal (slowly move away) while maintaining ability to attack.
3. **Execution (Combat):** 
   - **Condition:** Player detected and in range.
   - **Action:** 
     - If `combo_count >= 3`: Trigger `SPECIAL_ATTACK` (Fan Shot) and reset `combo_count`.
     - Else: Trigger `STANDARD_ATTACK` and increment `combo_count`.
4. **Roam (Fallback):** 
   - **Condition:** Player not detected or outside `engagement_zone_dist`.
   - **Action:** Wander randomly within a set radius of the spawn point.

## 3. Combat Systems

### Attack Patterns
- **Standard Attack:** Fires 1 arrow directly toward the player.
- **Special Attack (Combo Finisher):** Fires 3 arrows in a fan spread (-15°, 0°, +15°) to deny area and stop player dashes.

### Pipeline
- **Muzzle:** Projectiles spawn from a `Marker2D` node.
- **Cooldown:** An `AttackTimer` prevents spamming. The Archer must wait for the timer to finish before initiating another attack.
- **Projectiles:** `Arrow` (Area2D) moves linearly and calls `player.receive_hit()` on collision.

## 4. Movement & Environment

### Roaming & Ledge Detection
- **Wander Logic:** Picks a random point →
?→ walks →
?→ pauses →
?→ repeats.
- **Ledge Detection:** Uses a `RayCast2D` positioned in front of the Archer.
  - If `is_colliding() == false`, the Archer has reached a ledge.
  - **Reaction:** Stop →
?→ Flip Direction →
?→ Pick new roam point.

### Spacing Logic
- **Strategic Retreat:** When retreating or back-pedaling, the Archer calculates the vector away from the player and applies velocity in that direction.

## 5. Components
- **Nodes:**
  - `CharacterBody2D` (Root)
  - `AnimatedSprite2D` (Visuals)
  - `RayCast2D` (Ledge Detection)
  - `Marker2D` (Muzzle/Spawn Point)
  - `Timer` (Attack Cooldown)
  - `Area2D` (Player Detection)
- **Resources:**
  - `Arrow.tscn` (Projectile)
