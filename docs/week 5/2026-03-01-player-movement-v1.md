# Week 5: Player Movement & Combat Fundamentals

**Date:** February 2026 (Week 5)
**Goal:** Establish the core feel of the "Blade of the Samurai" through a responsive, multi-action movement system.

## Overview
Week 5 focused on implementing the primary verb set for the player. While the system was functional, it was characterized by "floaty" physics and several edge-case bugs (such as getting stuck in walls during dashes).

## Movement Mechanics

### 1. Locomotion (Walk & Run)
- **Walk:** Precise movement for platforming and exploration.
- **Run:** Triggered by a dedicated button or double-tap, allowing for faster traversal across the larger level types planned in Week 2.

### 2. Variable Jump Height
- **Mechanism:** Jump height is dynamically calculated based on the duration of the button press.
    - **Tap:** Executes a short "hop" for quick adjustments.
    - **Hold:** Reaches the maximum vertical velocity for high-altitude platforming.
- **Status:** Functional but prone to "infinite jump" bugs if the player collided with certain slopes.

### 3. Dash
- **Behavior:** A horizontal burst of speed used for both traversal and dodging.
- **Limitation:** At this stage, the dash lacked an "i-frame" (invulnerability) system and was purely for positioning.

## Combat Prototypes

### 1. Ground Attack (Basic Slash)
- The first iteration of the primary weapon swing. Designed to be a simple 3-frame animation to test hitbox registration.

### 2. Air Attack
- A specialized downward or forward strike performed while airborne.
- **Bug Note:** Gravity was not always correctly reapplied after an air attack, sometimes causing the player to "hover" momentarily.

## Technical Notes & Limitations

### Development State
- **Physics:** Built using `move_and_slide()` with basic gravity constants. 
- **Animation:** Placeholder sprites were used. Transitions between states (e.g., Run to Jump) often featured "jittery" frames.
- **Bugs:** The movement state machine was in its infancy; players could often dash through solid walls or trigger attacks during the wrong animation frames.
