# Week 8: Initial AI NPC Prototypes

**Date:** March 2026 (Week 8)
**Goal:** Implement and test the first iterations of non-player character (NPC) behavior using simple state-based logic.

## Overview
During Week 8, the focus shifted from pure player movement to environmental interaction. Two distinct, simple AI behaviors were prototyped to populate the testing environments.

## NPC Prototypes

### 1. The "Patroller" NPC
A mobile unit designed to monitor a specific path and react to the player's presence.
- **Behavior:** 
    - **Patrol State:** Moves between two defined markers in the environment.
    - **Detection:** Uses a basic RayCast2D/Area2D to check for the player in a forward-facing cone.
    - **Chase State:** If the player is detected, the NPC abandons its path to move toward the player's last known position.
- **Purpose:** Test basic pathing logic and player detection systems.

### 2. The "Stationary Guard" NPC
A defensive unit that remains in one spot but acts as a turret-like obstacle.
- **Behavior:**
    - **Idle State:** Remains stationary, rotating slightly to scan the area.
    - **Alert State:** If the player enters its detection radius, it plays an alert animation.
    - **Attack State:** Fires a simple projectile (or triggers a localized strike) if the player remains within range for too long.
- **Purpose:** Test combat triggers, projectile spawning, and stationary state management.

## Technical Notes & Limitations

### Development State
At this stage of development, the prototypes were functional but highly unpolished:
- **Visuals:** Sprite assets were still crude, low-fidelity placeholders used to verify scale and hitboxes rather than final aesthetic quality.
- **AI Reliability:** The logic was still quite buggy. Common issues included NPCs getting stuck on geometry, "jitters" when switching between patrol and chase states, and detection raycasts occasionally failing to trigger.

### Implementation Details
- **Implementation:** Both NPCs utilize a simple `if/else` or `match` state machine in GDScript.
- **Navigation:** Patrollers use basic `move_and_slide()` logic without complex pathfinding (A*) at this stage.
- **Integration:** These prototypes serve as the foundation for more advanced enemy types (Shoto, Zoner, etc.) planned for later development.
