# Boss AI Refinement Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Boss fairness and depth by locking facing during combos, implementing a 3s reactive block stance, and tuning knockbacks.

**Architecture:** 
- Modify `boss.gd` to remove direction snapping during `State.COMBAT`.
- Refactor `State.DEFEND` into a 3-second "Alert Stance" where animations only play on successful hits.
- Update `receive_hit` to handle the player knockback and stance-based damage reduction.
- Adjust `_perform_shout_knockback` for a 70-unit threshold.

**Tech Stack:** Godot GDScript

---

### Task 1: Lock Facing During Combos

**Files:**
- Modify: `scripts/boss.gd`

- [ ] **Step 1: Remove mid-combo re-facing**
In `_process_combat`, remove the call to `_update_facing(dir_x)`. The boss should only face the player once when `_start_attack("atk1")` is called.

- [ ] **Step 2: Add delay before re-facing in IDLE**
In `_evaluate_boss_logic`, only allow transitioning to `State.APPROACH` if `state_timer > 0.5`. This prevents the boss from instantly snapping back to the player after a combo finishes.

---

### Task 3: Refactor Defensive Stance (3s Duration)

**Files:**
- Modify: `scripts/boss.gd`

- [ ] **Step 1: Implement 3s Alert Stance**
Update `_evaluate_boss_logic` to have a 50% chance (`randf() < 0.5`) to enter `DEFEND` when in range.
In `change_state(State.DEFEND)`, remove the `sprite.play("defend")` call. The boss should look like he is in `idle` or just standing ready.

- [ ] **Step 2: Implement Hit-Triggered Block and Knockback**
In `receive_hit`, if `current_state == State.DEFEND`:
1. Play the "defend" animation.
2. Apply 90% damage reduction.
3. Calculate direction to player and apply a strong knockback to `attacker.velocity`.

---

### Task 3: Tune Shout Knockback

**Files:**
- Modify: `scripts/boss.gd`

- [ ] **Step 1: Update shout threshold**
In `_perform_shout_knockback`, change the distance check from 150 to **70 units**. Ensure the knockback force is significant enough to clear the area.

- [ ] **Step 2: Commit and Final Verification**

```bash
git add scripts/boss.gd
git commit -m "feat(boss): lock facing during combos and implement 3s reactive block stance"
```
