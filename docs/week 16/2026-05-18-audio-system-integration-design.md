# Global Audio System Design

**Date:** 2026-05-18
**Status:** Approved

## Goal
Implement a centralized, randomized, and dynamic audio system that synchronizes sound effects with specific animation frames and gameplay events.

## Architecture

### 1. AudioManager (Autoload Singleton)
A global manager that handles sound loading, player pooling, and randomization.

- **Audio Libraries:**
    - `hit`: `cut1.mp3`, `cut2.mp3`, `cut3.mp3`
    - `block`: `block1.mp3`, `block2.mp3`, `block3.mp3`, `block4.mp3`
    - `dash`: `dash.mp3`
    - `item_spawn`: `item_drop.wav`
    - `item_collect`: `item_pickup.wav`

- **Core Functionality:**
    - `play_sfx(library_name: String, pitch_min: float = 0.9, pitch_max: float = 1.1)`
    - Automatically manages a pool of `AudioStreamPlayer` nodes to allow overlapping sounds.
    - Randomly selects a variation from the chosen library.

### 2. Gameplay Integration

#### Combat Synchronization
- **Player Attacks:** Trigger `hit` library in `_on_frame_changed` when hitboxes are active.
- **Player Blocking:** Trigger `block` library in `receive_hit` when `current_state == DEFEND`.
- **Dashing:** Trigger `dash` sound upon state entry.

#### Item Events
- **Spawning:** `LootManager` calls `play_sfx("item_spawn")` when loot is instanced.
- **Collection:** `HealthItem` calls `play_sfx("item_collect")` before calling `queue_free()`.

## Success Criteria
- Sound effects play reliably and do not cut each other off.
- Variations in pitch and random selection make the audio feel organic rather than repetitive.
- "Cuts" and "Blocks" feel perfectly timed with the visual animations.
