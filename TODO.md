# Game Development TODO List

This document tracks the progress and future tasks for the development of our 2D Pixel Art Combat game.

## 🟢 Completed Tasks
- [x] **Basic Combat System:** Core logic for health, damage, and hitboxes.
- [x] **Player Controller:** Movement, Jump, Dash, Wall Jump, and Combo system.
- [x] **Enemy Archetypes:** Shoto, Rushdown, Zoner, Grappler, and Boss.
- [x] **Loot System:** Randomized 20% drop chance with 14 food items and "poo" joke.
- [x] **Player UI:** Extended 500px health bar (1200 HP) with flat values.
- [x] **Combat Polish:** 
    - [x] Perfect blocking (100% damage nullification).
    - [x] **Hit-Stop:** Global world freeze (0.05s) on every successful hit.
    - [x] **Directional Hit Spray:** Particles shoot away from the attacker's impact.
    - [x] **Death Particles:** Smoke "poof" effect when entities are defeated.
- [x] **Enemy AI Refinement:**
    - [x] **Idle Roam:** "Look Around" behaviors (40% chance) for all enemies.
    - [x] **Zoner Tactical Evasion:** Proactive dashing and full-speed backpedaling.
    - [x] **Zoner Triple Shot:** Special attack with adjustable height variation.
- [x] **Global Audio System:** 
    - [x] `AudioManager` singleton with sound pools and randomization.
    - [x] **Background Music:** Looping atmospheric track.
    - [x] **Dynamic Controls:** Individual pitch and volume settings for all SFX categories.
    - [x] **Combat SFX:** Integrated hit, block, and dash sounds for player and enemies.
    - [x] **Movement SFX:** Repeating footstep timer for the player.
    - [x] **Zoner SFX:** Synced bow draw and triple-shot arrow firing.
    - [x] **Boss SFX:** "Shout" vocal cues for heavy attacks and phase changes.

---

## 🟡 High Priority (Core Gameplay)
- [ ] **Main Menu:** A starting screen with "Start Game" and "Quit" buttons.
- [ ] **Game Over Screen:** Instead of just pausing, show a "You Died" screen with a "Restart" button.
- [ ] **Level System:** Implement a way to transition between the Testing Area and the Boss Level.
- [ ] **Parallax Backgrounds:** Use the Autumn Forest assets to create layers that move at different speeds for depth.
- [ ] **Ability Unlocks:** Perhaps the player can gain a double jump or a stronger special attack after defeating certain enemies.

## 🔵 Low Priority (Expansion & Tech)
- [ ] **Save/Load System:** Save current health or level progress.
- [ ] **Settings Menu:** Adjust volume or toggle full-screen mode.
- [ ] **Score System:** Track points for each enemy defeated.
- [ ] **Bestiary/Loot Gallery:** A screen to see all the food items you've collected.

---

## 💡 Suggestions from Gemini
1. **Destructible Environment:** Add crates or barrels that can be smashed and have a small chance to drop low-tier loot.
2. **Environment FX:** Add falling leaves (using particles) in the Autumn Forest to match the background assets.
3. **Camera Polish:** Add a "Look Ahead" feature where the camera shifts slightly in the direction the player is facing or moving.
