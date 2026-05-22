# Design Doc: Safe Autoload Refactoring

## Goal
Refactor all scripts to use safe node lookups for Autoloads (`AudioManager`, `LootManager`, `GameManager`) to prevent crashes if these nodes are missing or renamed.

## Background
The project mandate requires using `get_node_or_null("/root/AutoloadName")` instead of direct global name access. This ensures that the code gracefully handles the absence of a singleton.

## Proposed Changes

### 1. Pattern Implementation
For all method calls to Autoloads, the following pattern will be applied:
```gdscript
var <alias> = get_node_or_null("/root/<AutoloadName>")
if <alias>:
    <alias>.<method>(<args>)
```

### 2. Specific File Adjustments

#### `res://scripts/player.gd`
- Update `AudioManager` calls in footstep logic, hit logic, and dash logic.
- Update `LootManager` calls in hit logic.
- Update `GameManager` calls in death logic.

#### `res://scripts/grappler_enemy.gd`, `res://scripts/rushdown_enemy.gd`, `res://scripts/shoto_enemy.gd`, `res://scripts/zoner_enemy.gd`
- Update `AudioManager` calls for hits, blocks, and dashes.

#### `res://scripts/boss.gd`
- Update `GameManager.win_game()` call.

#### `res://scripts/health_item.gd`
- Update `AudioManager.play_sfx("item_collect")`.

#### `res://scripts/loot_manager.gd`
- Update `AudioManager.play_sfx("item_spawn")`. Note: Even though this is an Autoload itself, it should safely lookup other Autoloads.

#### `res://scripts/ui.gd`
- Refactor signal connections in `_ready()` to check for `GameManager` node existence before connecting.
- Use local lookup for `GameManager` methods.
- Note: Enums like `GameManager.State` are static and will remain as-is unless they cause runtime issues (they usually don't if the script is loaded, but if the class isn't registered it might fail. However, Godot Autoloads are classes).

## Verification Plan
1. **Static Analysis:** Use `mcp_godot_validate_script` on all modified files.
2. **Runtime Test:** Run `res://scenes/level.tscn` and verify SFX, game over, and victory triggers still work.
3. **Missing Singleton Test:** (Optional/Mental) Ensure that if a singleton is disabled in Project Settings, the game doesn't crash on these calls.
