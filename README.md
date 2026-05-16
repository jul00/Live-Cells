# 🗡️ LiveCells (Working Title)
**Course:** CMSC 197: GDD  
**Objective:** Develop a semester-long original game from concept to deployment, maintaining a "Living Document" as a technical specification.

## 📌 Project Overview
- **Hook:** A high-octane samurai action platformer featuring dynamic combat patterns and lethal precision to overthrow a tyrant's castle.
- **Genre:** Platformer-Fighting
- **Core Loop:** Explore the Castle $
ightarrow$ Fight through waves of enemies $
ightarrow$ Defeat the Boss $
ightarrow$ Free the realm from tyranny.
- **Inspirations:** *Dead Cells*, *Hades*
- **Technical Focus:** Dynamic-pattern combat designed for maximum player engagement.
- **Repository:** GitHub with semantic commits throughout
- **Weight:** 40% of final grade

---

## 📅 Development History & Milestones

### Week 2: Living Concept Document (10%) ✅
- **Goal:** Establish vision and feasibility.
- **Details:**
  - **Title:** LiveCells
  - **Tagline:** "Precision steel against an empire of tyranny."
  - **Core Loop:** Combat-driven exploration of a hostile castle with a focus on mastery of the blade.
  - **Technical Feasibility:** Implementation of Finite State Machines (FSM) for character states and a profile-based hitbox system for diverse attack patterns.
  - **Scope:** MVP focuses on the core combat feel and 1-2 levels.

### Week 5: First Playable Prototype (20%) ✅
- **Goal:** Demonstrate the core hook.
- **Deliverable:** Playable build with the "Dynamic Combat" feel.
- **Key Implementations:**
  - 3-hit combo system with grace timers.
  - Fluid movement: Dashing, Wall-sliding, and Wall-jumping.
  - Basic win/loss conditions.

### Week 8: Alpha Check-In (5%) ✅
- **Goal:** Catch architectural issues early.
- **Deliverable:** Alpha build with integrated combat systems.
- **Architecture:** 
  - `CombatEntity` base class to handle health and hitbox activation.
  - State-driven logic in `Player.gd` to ensure mutually exclusive actions (e.g., cannot move while attacking).
  - Signal-based communication for hit detection and health updates.

### Week 12: Midterm Presentation (20%) ✅
- **Goal:** Comprehensive systems review.
- **Deliverable:** 20-minute presentation and a stable combat demo.
- **Systems Documented:** 
  - **Combat Patterns:** Implementation of various attack profiles (Light, Heavy, Special).
  - **Enemy AI:** Basic FSMs for enemy behavior (Idle $
ightarrow$ Chase $
ightarrow$ Attack).
  - **Asset Pipeline:** Integration of pixel art assets and animation states.

### Week 15: Beta Check-In (5%) ✅
- **Goal:** Feature lock and polish.
- **Status:** Feature Locked.
- **Scope Adjustments:** 
  - ~~Boon/Upgrade System~~ $
ightarrow$ **CUT** due to time constraints to ensure combat polish.
- **Polish Focus:** Refined hit-stop, screen shake, and UI/HUD professionalism.

### Week 16: Final Presentation (40%) 🎯
- **Goal:** Final delivery and reflection.
- **Final Deliverables:** Polished game build + Final Technical Design Document.
- **Reflection:** Analyzing the effectiveness of the dynamic combat patterns and the scalability of the `CombatEntity` architecture.

---

## 📝 Living Document Guidelines

### Formatting & Standards
- **File Path:** `/docs/LiveCells_DesignDoc`
- **Acceptable Formats:** Markdown (.md) + PDF
- **Visuals:** Architecture diagrams (FSMs, scene trees), gameplay screenshots, and syntax-highlighted code snippets.
- **Writing Standards:**
  - **Be Specific:** Quantify details (e.g., "Player has 3 lives").
  - **Show Rationale:** Explain *why* a decision was made (e.g., choosing FSMs over behavior trees for simplicity).
  - **Reference Code:** Link directly to files/functions in the repository.
  - **Update Ruthlessly:** Use strikethroughs for cut features (e.g., the Boon system).

### Diagramming Tools
- **draw.io** (Web-based)
- **Mermaid** (Text-based in Markdown)
- **Godot scene exports** (Copy Node Path)

---

## ✅ Final Deliverable Checklist
- [ ] Game builds for Windows/Linux/macOS (at least one)
- [ ] Complete Living Document (8-10 pages, in `/docs/`)
- [ ] GitHub repository with full commit history
- [ ] `README.md` with installation instructions and controls
- [ ] Gameplay trailer (Optional but recommended)
