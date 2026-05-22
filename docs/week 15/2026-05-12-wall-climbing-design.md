# Wall Climbing & Jumping Design
Date: 2026-05-12
Status: Proposed

## Overview
Implementation of "sticky" wall mechanics including initial contact, sliding, and a standard platformer wall jump that pushes the player upward and away from the wall.

## 1. Wall State Management
A new state `State.WALL` will be introduced to handle all wall-related behavior.

### Transitions To `State.WALL`
- **Condition:** `!is_on_floor()` AND `is_on_wall()`.
- **Entry Action:** Play `wall-contact` animation to indicate impact.

### Behavior in `State.WALL`
- **Wall Slide:** 
    - After `wall-contact` finishes (or immediately), play the looping `wall-slide` animation.
    - **Gravity Modification:** Cap the downward velocity to a constant `WALL_SLIDE_SPEED` to create a slow descent.
- **Exit Conditions:**
    - `is_on_floor()` →
?→ Transition to `State.MOVE`.
    - `!is_on_wall()` →
?→ Transition to `State.JUMP`.
    - Jump Input →
?→ Trigger Wall Jump.

## 2. Wall Jump Mechanics
A standard platformer-style jump that launches the player away from the wall.

### Logic
- **Trigger:** Pressing the "Jump" button while in `State.WALL`.
- **Physics Impulse:**
    - **Vertical:** Apply `JUMP_VELOCITY`.
    - **Horizontal:** Apply a burst in the opposite direction of the wall normal.
    - Formula: `velocity = Vector2(wall_normal.x * WALL_JUMP_PUSH, JUMP_VELOCITY)`
- **Animation:** Play `wall-jump` animation.
- **State Transition:** Transition immediately to `State.JUMP`.

## 3. Animation Sequence
| Action | Animation | Loop | Trigger |
| :--- | :--- | :--- | :--- |
| **Initial Hit** | `wall-contact` | No | Entry into `State.WALL` |
| **Sustained Slide**| `wall-slide` | Yes | After contact, while in `State.WALL` |
| **Wall Launch** | `wall-jump` | No | Jump input while in `State.WALL` |

## 4. Technical Implementation Details
- **Modify:** `scripts/player.gd`
- **New Constants:**
    - `WALL_SLIDE_SPEED`: The maximum downward velocity during a slide.
    - `WALL_JUMP_PUSH`: The horizontal force applied during a wall jump.
- **Node Reference:** Use `AnimatedSprite2D` for animation playback.
- **Signal:** Use `animation_finished` to transition from `wall-contact` to `wall-slide`.
