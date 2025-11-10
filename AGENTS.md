# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Viber Cats is a cat-themed survivors-like game built in Godot 4.5 with an isometric 3D perspective. The player controls a cat defending against waves of enemies using automated cat-themed attacks and collecting powerups.

**Engine:** Godot 4.5 (Forward Plus renderer)
**Language:** GDScript
**Current Phase:** Phase 1 (Core Gameplay) - Nearly Complete

## Running the Game

### From Godot Editor
```bash
# Open project in Godot 4.5+
godot --editor .

# Or run directly (F5 in editor)
godot scenes/main.tscn
```

### From Command Line
```bash
# Run the game
godot --path . scenes/main.tscn

# Check Godot version
godot --version
```

## Project Architecture

### Autoload Singletons (Global State)

Two singleton scripts are autoloaded and available globally throughout the game:

1. **PlayerStats** (`scripts/player_stats.gd`)
   - Manages XP, level, and hunger bar (XP bar)
   - Emits signals when level-up occurs
   - Accessed via `PlayerStats.add_xp()`, `PlayerStats.current_level`, etc.

2. **PowerupManager** (`scripts/powerup_manager.gd`)
   - Contains all 12 cat-themed powerups with rarity tiers (Common → Legendary)
   - Handles weighted random selection based on rarity
   - Manages banished powerups and stacking
   - Accessed via `PowerupManager.get_random_powerups()`, `PowerupManager.apply_powerup()`, etc.

### Core System Interactions

#### Player → Enemy Combat Flow
1. Player (`scripts/player.gd`) uses `find_nearest_enemy()` to locate enemies in "enemies" group
2. If enemy within `attack_range`, calls `perform_attack()`
3. Attack calls enemy's `take_damage()` method
4. Enemy (`scripts/enemy.gd`) dies, emits `died` signal, spawns cat food, calls `queue_free()`

#### Enemy AI & Navigation
- Enemies use **NavigationAgent3D** for pathfinding around obstacles
- Navigation mesh must be baked in Godot Editor for pathfinding to work
- Key NavigationAgent3D settings:
  - `target_desired_distance`: Should match `attack_range` (1.5) so navigation finishes when enemy reaches attack position
  - `path_desired_distance`: Waypoint threshold (0.5)
- Gravity must be applied every `_physics_process` frame, not conditionally
- Enemies spawn at y=0.6 and fall to y≈0.4 (nav mesh surface)

#### XP & Level-Up Flow
1. Enemy dies → spawns CatFood (`scripts/cat_food.gd`)
2. CatFood magnetically moves toward player
3. Player collects CatFood → calls `PlayerStats.add_xp()`
4. When XP threshold reached → `PlayerStats` emits `level_up` signal
5. HUD (`scripts/hud.gd`) shows level-up screen
6. Player selects powerup → `PowerupManager.apply_powerup()` applies effects

### Scene Structure

```
scenes/main.tscn (Main game world)
├── DirectionalLight3D (lighting)
├── WorldEnvironment (environment settings)
├── NavigationRegion3D (for enemy pathfinding)
│   ├── Ground (StaticBody3D with collision)
│   ├── Tree × 4 (obstacles)
│   └── Rock × 3 (obstacles)
├── Camera3D (isometric view with camera_follow.gd)
├── Player (player.tscn instance)
├── EnemySpawner (Node3D with enemy_spawner.gd)
├── HUD (ui/hud.tscn instance)
└── LevelUpScreen (ui/levelup_screen.tscn instance)
```

### Important Implementation Details

#### Navigation System
- **NavigationRegion3D** must be a parent of all collidable static geometry
- Navigation mesh has baked vertex/polygon data at y=0.4
- Obstacles (trees, rocks) must be children of NavigationRegion3D to be parsed during baking
- Enemy NavigationAgent3D configuration is critical:
  - `target_desired_distance = 1.5` (matches attack range)
  - Too high causes premature "navigation finished"
  - Too low causes "target not reachable" at long distances

#### Physics & Movement
- Player and enemies are **CharacterBody3D** (kinematic physics)
- Gravity (9.8 m/s²) must be applied in `_physics_process` every frame
- Both player and enemies call `move_and_slide()` after setting velocity
- Enemy move speed (4.0) is slightly slower than player (5.0) for balanced gameplay

#### Groups for Entity Management
- Player adds self to `"players"` group
- Enemies add self to `"enemies"` group
- Scripts use `get_tree().get_nodes_in_group()` for cross-entity references

## Key Technical Constraints

### Godot 4.5 Specific
- Uses `CharacterBody3D.move_and_slide()` (no parameters, uses velocity property)
- Input actions use `Input.get_vector()` for movement
- Scene instantiation uses `scene.instantiate()` not `instance()`
- Signals use `.connect()` with callable syntax: `signal_name.connect(method)`

### Scene Files
- Scene files (.tscn) are text-based but complex
- Navigation mesh baking must be done in Godot Editor (cannot be scripted)
- Most scene configuration requires the editor UI

### Code Style
- Use `@export` for editor-exposed variables
- Use `@onready` for node references
- Class names with `class_name` keyword (e.g., `class_name Player`)
- Type hints encouraged: `var health: float = 100.0`
- Signals declared with `signal signal_name(params)`

## Common Issues & Solutions

### Enemy Navigation Problems
**Symptom:** Enemies not moving toward player
- Check that NavigationRegion3D has baked navigation mesh (vertices/polygons not empty)
- Verify Ground is child of NavigationRegion3D
- Ensure `target_desired_distance` is set correctly (1.5 units)
- Check enemies are on floor (`is_on_floor()` returns true)
- Verify gravity is applied every frame in `_physics_process`

**Symptom:** "Target not reachable" errors
- Usually means target is outside nav mesh bounds or `target_desired_distance` too small
- Check player and enemy Y positions match nav mesh surface (y≈0.4-0.6)

### Physics Issues
**Symptom:** Entities floating or not affected by gravity
- Gravity must be applied **before** conditional checks, not inside them
- Common mistake: applying gravity only when `is_target_reachable()` is true

### Group Management
**Symptom:** Player can't find enemies or vice versa
- Verify `add_to_group()` called in `_ready()`
- Use `call_deferred("method_name")` for setup that needs scene tree ready

## Assets & Dependencies

**Kenny Starter Kit (Basic Scene)** - Provides placeholder 3D models
- Trees and rocks for obstacles
- Basic shapes and materials
- Installed via Godot AssetLib

**Future:** Cat-themed custom models will replace Kenny assets

## Development Roadmap

**Phase 1 (Current):** Core gameplay - Player, enemies, combat, XP, powerups ✅
**Phase 2 (Planned):** Menu systems - Title screen, difficulty, character selection
**Phase 3 (Planned):** Multiplayer - Local co-op (2 players), Steam integration, online play

## Debugging

### Enable Debug Output
Temporarily add print statements in key methods:
- `enemy.gd`: `_physics_process`, `move_towards_target`
- `player.gd`: `perform_attack`, `take_damage`
- `player_stats.gd`: `add_xp`, `_check_level_up`

### Check Scene Tree
In Godot Editor, use Remote tab during play to inspect:
- Node counts (enemy count, cat food instances)
- Node properties (positions, velocities)
- Group membership

### Navigation Debugging
Enable NavigationServer debug in Godot Editor:
- Debug → Visible Collision Shapes
- Shows navigation mesh and paths in real-time
