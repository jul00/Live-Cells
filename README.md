# 🗡️ LiveCells

A high-octane 2D Pixel Art Samurai action-platformer built in Godot 4. Features dynamic combat patterns, tactical enemy AI, and visceral visual feedback.

---

## 📌 Project Overview
- **Hook:** Precision steel against an empire of tyranny.
- **Genre:** Action-Platformer / Fighting
- **Core Loop:** Explore the Castle → Fight through tactical enemy waves → Defeat the Boss.
- **Technical Focus:** Profile-based hitbox system, fluid FSM-driven movement, and centralized gameplay management.

---

## 🎮 Key Features

### ⚔️ Combat System
- **Combo System:** A responsive 3-hit combo system with grace timers for seamless transitions.
- **Advanced Defense:** 
    - **Perfect Block:** 100% damage nullification when timed correctly.
    - **Fluid Evasion:** Dashing with invulnerability frames.
- **Profile-Based Hitboxes:** Attacks use unique data profiles (Position, Size, Damage) for precise collision.

### 🧠 Tactical Enemy AI
- **Archetypes:**
    - **Shoto (Balanced):** Uses a mix of approach and defensive tactics.
    - **Rushdown (Aggressive):** Relentless pressure with lunging attacks and counters.
    - **Zoner (Ranged):** Maintains distance with proactive dashing and a triple-shot arrow sequence.
    - **Grappler (Heavy):** Slow but powerful hits that punish mistakes.
- **Life-like Behaviors:** Enemies feature idle "look around" behaviors and HP-based "stagger breaker" evasions.

### 🍖 Loot & Economy
- **Dynamic Drops:** Enemies have a randomized chance to drop health items upon death.
- **Health Items:** 14 unique food sprites with varying percentage-based healing values.
- **Joke Item:** The "Poo" item which penalizes the player for 20% health.

### 🎨 Visuals & "Juice"
- **Hit-Stop:** Global world freeze (0.05s) on every successful hit for massive impact.
- **Directional Spray:** Hit particles spray away from the point of impact.
- **Death FX:** Procedural smoke "poof" particles for defeated entities.
- **UI:** Extended 500px health bar with real-time flat value tracking (1200 Max HP).

### 🔊 Audio System
- **Centralized Management:** `AudioManager` singleton with sound pools for overlapping SFX.
- **Dynamic Variation:** Randomized pitch and asset selection for every strike and block.

---

## ⌨️ Controls
| Action | Key |
| :--- | :--- |
| **Move** | `A` / `D` |
| **Jump** | `Space` |
| **Attack** | `Left Click` |
| **Defend / Block** | `Right Click` |
| **Dash** | `Shift` |

---

## 🛠️ Tech Stack
- **Engine:** Godot 4.x
- **Language:** GDScript 2.0
- **Assets:** 2D Pixel Art (Autumn Forest, Samurai Sets)

---

## 📂 Project Structure
- `/scenes`: Game objects, characters, and UI levels.
- `/scripts`: Logic for combat, AI, and systems management.
- `/assets`: Pixel art spritesheets and SFX.
- `/docs`: Technical specifications and development roadmap.

---

## Audio:
- https://www.youtube.com/shorts/1GwOKlggHWI
- https://www.youtube.com/results?search_query=japanese+background+music+for+vlog
- https://www.youtube.com/watch?v=pqEn9icjK0I
- https://www.youtube.com/watch?v=Ds9zM_tfTKA
- https://raou.itch.io/dark-dun
- https://itch.io/s/110075/samurai-bundle-2d-pixel-art