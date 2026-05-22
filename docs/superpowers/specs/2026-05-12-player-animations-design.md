# Player Animation & Combat System Design
Date: 2026-05-12
Status: Proposed

## Overview
Implementation of a state-driven animation system for the Player character to handle movement, combat combos, and special abilities with high visual fidelity and fluid transitions.

## 1. State Machine Architecture
The player's behavior and animations will be managed by a state machine to ensure mutually exclusive states and clean transitions.

### States
| State | Active Animations | Transitions To |
| :--- | :--- | :--- |
| `MOVE` | `idle`, `walk` | `JUMP`, `ATTACK`, `DASH`, `DEFEND`, `HURT` |
| `JUMP` | `jump-start` →
?→ `jump-transition` →
?→ `jump-fall` | `MOVE` (on landing), `ATTACK` (air-atk), `HURT` |
| `ATTACK` | `atk1`, `atk2`, `atk3`, `special-atk`, `air-atk` | `MOVE` (on finish), `ATTACK` (combo), `HURT` |
| `DASH` | `dash` | `MOVE` (on finish), `HURT` |
| `DEFEND` | `defend` | `MOVE` (on release), `HURT` |
| `HURT` | `hurt` | `MOVE` (on finish), `DEATH` |
| `DEATH` | `death` | None (Terminal) |

## 2. Combat Combo System
A buffered combo system will be used for the basic attack chain.

### Logic
- **Chain:** `atk1` →
?→ `atk2` →
?→ `atk3`.
- **Combo Step:** An integer `combo_step` tracks the current attack index.
- **Buffering:** 
    - If "attack" is pressed during the last 30% of the current attack animation, a `next_attack_queued` flag is set to `true`.
    - Upon animation completion, if `next_attack_queued` is `true`, the next attack in the chain is triggered immediately.
- **Reset:** The combo resets to `atk1` if:
    - The attack chain completes (`atk3` finishes).
    - The player performs a different action (Dash, Defend, Special).
    - Too much time passes between attacks.

## 3. Ability Specifications

### Special Attack (`special-atk`)
- **Trigger:** `"special"` action.
- **Priority:** High. Cannot be interrupted by normal attacks.
- **Outcome:** Returns to `MOVE` state after completion.

### Dash (`dash`)
- **Trigger:** `"dash"` action.
- **Behavior:** Locks movement input in the dash direction.
- **Outcome:** Returns to `MOVE` state after completion.

### Defend (`defend`)
- **Trigger:** Hold `"defend"` action.
- **Behavior:** Continuous animation while held.
- **Outcome:** Returns to `MOVE` state upon release.

### Jump Sequence
Animations are chained based on vertical velocity (`velocity.y`):
1. `jump-start`: Triggered on jump input.
2. `jump-transition`: Triggered when `abs(velocity.y) < threshold` (peak of jump).
3. `jump-fall`: Triggered when `velocity.y > 0` (falling).

### Air Attack (`air-atk`)
- **Trigger:** `"attack"` action while in `JUMP` state.
- **Outcome:** Returns to `JUMP` state after completion.

## 4. Technical Implementation Details
- **Node Reference:** Use `AnimatedSprite2D` for animation playback.
- **Signals:** Connect to `animation_finished` signal to handle state transitions for non-looping animations.
- **Input Map:**
    - `"attack"` →
?→ Basic combo / Air attack.
    - `"special"` →
?→ Special attack.
    - `"dash"` →
?→ Dash.
    - `"defend"` →
?→ Defend.
    - `"ui_accept"` (or custom jump) →
?→ Jump.
