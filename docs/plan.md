# Viber Cats - Isometric Survivors-like Game

## Project Overview
A cat-themed Survivors-like game similar to Vampire Survivors, Spell Brigade, and Deep Rock Galactic: Survivors, built in Godot 4.5 with an isometric perspective. The player controls a heroic cat defending against waves of enemies using cat-themed weapons and abilities.

---

## 📊 Current Status: Phase 1 Complete! 🎮

**Last Updated:** 2025-01-07

### Phase 1: Core Gameplay
- **Scripts:** 12/12 ✅
- **Scenes:** 9/9 ✅
- **Gameplay:** 100% ✅ (Navigation working!)
- **Status:** Ready for Phase 2

### Recent Fixes (2025-01-07)
- ✅ Fixed enemy navigation - enemies now properly chase player
- ✅ Resolved gravity application - moved to main physics loop
- ✅ Fixed `target_desired_distance` setting (1.5 to match attack range)
- ✅ Adjusted enemy speed to 4.0 (balanced vs player 5.0)
- ✅ Removed debug print statements

### Resolved Issues
- ✅ NavigationMesh resource missing (2025-01-06)
- ✅ WorldEnvironment missing environment (2025-01-06)
- ✅ Enemies not applying gravity (2025-01-07)
- ✅ Enemies floating/not landing on floor (2025-01-07)
- ✅ Navigation `is_target_reachable()` returning false (2025-01-07)
- ✅ Navigation finishing prematurely (2025-01-07)

---

## Implementation Plan

### Phase 1: Core Gameplay ✅ COMPLETE

#### 1. Main Game Scene ✅
- ✅ 3D scene with isometric camera view (tilted 45° angle)
- ✅ Camera follows player and keeps them centered on screen
- ✅ Camera pans smoothly as player moves
- ✅ Static map with ground plane (100x100)
- ✅ Collidable environmental objects (4 trees, 3 rocks)
- ✅ NavigationRegion3D with baked NavigationMesh
- ✅ Player and enemies navigate around obstacles
- ✅ Single main map (scenes/main.tscn)

#### 2. Player System (Cat Character) ✅
- ✅ WASD + controller movement support
- ✅ Health system with health bar UI
- ✅ Automated cat-themed attacks that target nearest enemy
- ✅ CharacterBody3D with collision
- ✅ Smooth acceleration/friction movement

#### 3. Enemy System ✅
- ✅ Off-screen spawner that continuously generates enemies
- ✅ AI that follows the player using NavigationAgent3D pathfinding
- ✅ Enemies navigate around obstacles (trees, rocks)
- ✅ Difficulty scaling (spawn rate increases over time)
- ✅ Cat food drops on death (serves as XP)
- ✅ Attack system with cooldown

#### 4. Progression & Powerup System ✅
- ✅ Cat food collection with magnetic pickup (acts as XP)
- ✅ Hunger bar (XP bar) UI that fills up to trigger level-up
- ✅ Level-up pauses game and shows powerup selection screen
- ✅ Cat-themed powerup system with rarity tiers (Common, Uncommon, Rare, Epic, Legendary)
- ✅ Weighted random selection based on rarity (60% Common → 1% Legendary)
- ✅ 3-4 powerup choices presented on level-up
- ✅ 12 unique cat-themed powerups
- ✅ Level-up meta-options:
  - ✅ **Skip**: Skip this level-up
  - ✅ **Banish**: Remove a powerup from the pool permanently
  - ✅ **Reroll**: Reroll the current powerup choices

#### 5. Weapon System (Planned Enhancement) 🔫
- **8 unique cat-themed weapons** to choose from
- **Weapon unlock levels:** Players choose a new weapon at levels 6, 12, 18, and 21
- Each weapon has unique attack patterns and effects
- Weapons stack with existing powerups for synergy
- Random selection of 3 weapons offered at weapon unlock levels

**Planned Weapon Types:**
1. **Claw Strike** - Fast melee swipes in front of player
2. **Furball Launcher** - Projectiles that bounce off walls
3. **Tail Whip** - Spinning area attack around player
4. **Yarn Ball** - Seeking projectiles that home in on enemies
5. **Catnip Bomb** - Area-of-effect explosion with damage over time
6. **Laser Pointer** - Continuous beam that pierces enemies
7. **Fish Slap** - Knockback melee with wide arc
8. **Scratching Post** - Stationary turret that auto-attacks

**Implementation Notes:**
- Characters start with one primary weapon (based on cat choice)
- Weapon selection appears instead of powerup selection at milestone levels
- Players can have up to 5 total weapons (starter + 4 choices)
- Each weapon can be upgraded through powerups (increased damage, range, cooldown reduction)

### Phase 2: Menu & Selection Systems (Planned)

#### 5. Title Screen
- Game start option
- Basic menu navigation
- Built using Godot's GUI system (Control nodes, Buttons, Labels, etc.)
- Multiplayer options (Host, Join, Local Co-op)

#### 6. Difficulty Selection
- Multiple difficulty levels
- Difficulty modifiers (enemy speed, spawn rate, etc.)
- GUI-based selection interface

#### 7. Character Selection 🐱
- **Multiple playable cats** with unique starting weapons
- Each cat starts with a different primary weapon type
- Character selection UI with cat portraits
- System designed for character expansion
- GUI-based character cards and selection
- Support for multiple player character selections in multiplayer

**Planned Cat Characters:**
- TBD based on weapon types (e.g., Scratchy the Melee Cat, Whiskers the Ranger Cat, etc.)

### Phase 3: Multiplayer Systems (Future)

#### 8. Local Multiplayer (Couch Co-op)
- Support for 2 local players on same screen
- Split input handling (keyboard + gamepad, or 2 gamepads)
- Shared camera view that keeps both players visible
- Local players can join online sessions together

#### 9. Online Multiplayer
- Steam integration for matchmaking and invites
- Host/Join lobby system
- Network synchronization for:
  - Player positions and actions
  - Enemy spawning and AI
  - Damage and health states
  - Cat food pickups
  - Powerup selections
- Support for 2 local players joining online game as a party
- Player count: TBD (2-4 players recommended)

## File Structure

```
scenes/
  ├── main.tscn                    # Main game world with static map
  ├── player.tscn                  # Player character
  ├── enemy.tscn                   # Enemy character
  ├── cat_food.tscn                # Cat food collectible (XP)
  ├── environment/
  │   ├── tree.tscn                # Collidable tree obstacle
  │   ├── rock.tscn                # Collidable rock obstacle
  │   └── obstacle_base.tscn       # Base scene for obstacles
  ├── menus/                       # (Phase 2)
  │   ├── title_screen.tscn
  │   ├── difficulty_select.tscn
  │   └── character_select.tscn
  └── ui/
      ├── hud.tscn                 # Health/XP/Level UI
      ├── levelup_screen.tscn      # Powerup selection on level-up
      └── powerup_choice.tscn      # Individual powerup display card

scripts/
  ├── player.gd                    # Player (cat) movement & combat
  ├── enemy.gd                     # Enemy AI
  ├── enemy_spawner.gd             # Spawn management
  ├── cat_food.gd                  # Cat food collection (XP)
  ├── health_component.gd          # Reusable health system
  ├── player_stats.gd              # Level/hunger tracking
  ├── powerup.gd                   # Cat-themed powerup data resource
  ├── powerup_manager.gd           # Powerup pool and selection logic
  ├── game_manager.gd              # Global state (difficulty, character choice)
  └── multiplayer/                 # (Phase 3)
      ├── network_manager.gd       # Network setup and Steam integration
      ├── player_sync.gd           # Player state synchronization
      └── lobby_manager.gd         # Lobby and matchmaking

docs/
  └── plan.md                      # This file
```

## Technical Notes

- Using Godot 4.5 with Forward Plus renderer
- **3D isometric view**: Camera positioned at 45° angle looking down at the game world
- **Camera system**: Follows player character(s), keeping them centered on screen
  - Single player: Camera follows solo player
  - Local co-op: Camera adjusts to keep both players visible
- **Initial Assets**: Using Kenny Starter Kit (Basic Scene) from Godot Asset Library
  - Source: https://godotassetlibrary.com/asset/WIB7Pt/starter-kit-basic-scene
  - Provides basic 3D shapes and materials for prototyping
  - Tree and rock models from Kenny assets for obstacles
  - Can be easily replaced with custom cat-themed assets later
- **Game World**: Single static map with placed obstacles
  - Ground plane with collision
  - Static collidable objects (trees, rocks) placed throughout map
  - NavigationRegion3D for enemy pathfinding around obstacles
- Player and enemies use CharacterBody3D
- **UI System**: Using Godot's built-in GUI system with Control nodes (Buttons, Labels, Panels, etc.)
  - HUD overlays use CanvasLayer for always-on-top display
  - Menus built with VBoxContainer, HBoxContainer for layout
  - Level-up screen uses GUI panels and buttons
- **Multiplayer Architecture** (Phase 3):
  - Steam integration using GodotSteam or similar plugin
  - Client-server model with authoritative server
  - Local co-op: 2 players max on same machine
  - Online: Support for 2 local players joining as party
  - Network code designed to be added later without major refactoring
- Focus on gameplay mechanics first

## Core Mechanics

### Movement
- 8-directional movement (WASD or analog stick)
- Smooth controller support
- Player collides with environment obstacles (trees, rocks)
- Player must navigate around obstacles

### Combat
- Automated attacks trigger periodically
- Attacks target nearest enemy within range
- Damage numbers/feedback on hit
- Projectiles and effects respect obstacle collision

### Enemy Spawning & AI
- Enemies spawn outside camera view
- Spawn rate increases over time
- AI uses NavigationAgent3D for pathfinding
- Enemies navigate around obstacles to reach player
- Multiple enemy types (future expansion)

### Progression & Powerups
- Cat food drops from defeated enemies
- Hunger bar fills as player collects cat food
- When hunger bar fills, game pauses and level-up screen appears
- Player chooses from 3-4 randomly selected cat-themed powerups
- Powerup selection is weighted by rarity:
  - **Common** (60%): Basic stat boosts, frequent abilities
  - **Uncommon** (25%): Moderate upgrades, useful abilities
  - **Rare** (10%): Strong upgrades, powerful abilities
  - **Epic** (4%): Very powerful upgrades, game-changing abilities
  - **Legendary** (1%): Extremely rare, run-defining abilities

#### Level-up Meta Options
- **Skip**: Close level-up screen without selecting (useful late game)
- **Banish**: Remove one powerup from appearing for rest of run
- **Reroll**: Get new set of powerup choices (limited uses or cost)

#### Cat-Themed Powerup Types

**Weapons & Attacks:**
- **Claw Swipe** - Melee damage upgrade
- **Furball Projectiles** - Ranged attack that shoots furballs
- **Zoomies** - Dash attack in a straight line
- **Tail Whip** - Area attack around the player
- **Catnip Cloud** - Area-of-effect damage aura
- **Laser Pointer** - Piercing beam attack
- **Scratching Post** - Stationary damage-dealing turret

**Movement & Agility:**
- **Nine Lives** - Extra health/revival
- **Cat Reflexes** - Increased movement speed
- **Wall Climb** - Temporary invincibility/dodge
- **Landing on Feet** - Damage resistance

**Utility & Collection:**
- **Curious Cat** - Increased cat food magnet range
- **Purrfect Timing** - Cooldown reduction
- **Catnap** - Health regeneration over time
- **Whisker Sense** - Show nearby enemies
- **Food Critic** - Better quality cat food drops (more XP per drop)

**Legendary Abilities:**
- **Supreme Predator** - Massive damage boost to all attacks
- **Cat's Cradle** - Creates protective barrier
- **Meow Mix** - Combines multiple weapon effects

### Health System
- Player and enemies have health pools
- Visual health bars
- Game over on player death

---

## 📋 Completed Implementation Details

### Scripts Created (12/12)
1. ✅ **scripts/player.gd** - Player movement, combat, health (Player class)
2. ✅ **scripts/enemy.gd** - Enemy AI with NavigationAgent3D (Enemy class)
3. ✅ **scripts/enemy_spawner.gd** - Off-screen spawning with scaling (EnemySpawner class)
4. ✅ **scripts/cat_food.gd** - Magnetic collectible XP (CatFood class)
5. ✅ **scripts/player_stats.gd** - XP/level tracking (Autoload singleton)
6. ✅ **scripts/powerup_manager.gd** - Powerup pool management (Autoload singleton)
7. ✅ **scripts/powerup.gd** - Powerup resource definition (Resource class)
8. ✅ **scripts/health_component.gd** - Reusable health component
9. ✅ **scripts/camera_follow.gd** - Smooth isometric camera
10. ✅ **scripts/hud.gd** - Health/hunger/level display
11. ✅ **scripts/levelup_screen.gd** - Powerup selection UI
12. ✅ **scripts/powerup_choice.gd** - Individual powerup card UI

### Scenes Created (9/9)
1. ✅ **scenes/main.tscn** - Complete game world
   - DirectionalLight3D with shadows
   - WorldEnvironment with Environment resource
   - Ground plane (100x100) with collision
   - NavigationRegion3D with baked NavigationMesh
   - 4 Tree obstacles, 3 Rock obstacles
   - Camera3D with camera_follow.gd
   - Player instance
   - EnemySpawner node
   - HUD instance
   - LevelUpScreen instance
2. ✅ **scenes/player.tscn** - Orange capsule player with CharacterBody3D
3. ✅ **scenes/enemy.tscn** - Red box enemy with NavigationAgent3D
4. ✅ **scenes/cat_food.tscn** - Yellow sphere collectible with Area3D
5. ✅ **scenes/environment/tree.tscn** - Brown cylinder obstacle (StaticBody3D)
6. ✅ **scenes/environment/rock.tscn** - Gray sphere obstacle (StaticBody3D)
7. ✅ **scenes/ui/hud.tscn** - HUD with ProgressBars and Labels
8. ✅ **scenes/ui/levelup_screen.tscn** - Level-up powerup selection menu
9. ✅ **scenes/ui/powerup_choice.tscn** - Powerup card component

### Configuration Complete
- ✅ Input actions configured (move_forward, move_back, move_left, move_right)
- ✅ WASD keyboard + controller analog stick support
- ✅ Autoloads registered (PlayerStats, PowerupManager)
- ✅ Main scene set to scenes/main.tscn
- ✅ Project name: "Viber Cats"

### Cat-Themed Powerups (12 Total)

**Common (60% spawn rate):**
1. Claw Swipe - Increased melee damage
2. Cat Reflexes - Movement speed boost
3. Curious Cat - Larger magnet range for cat food

**Uncommon (25% spawn rate):**
4. Furball Projectiles - Ranged hairball attack
5. Purrfect Timing - Reduced ability cooldowns
6. Nine Lives - Extra health/max health

**Rare (10% spawn rate):**
7. Tail Whip - Area-of-effect spin attack
8. Catnap - Health regeneration over time

**Epic (4% spawn rate):**
9. Laser Pointer - Piercing beam weapon
10. Catnip Cloud - Damaging aura around player

**Legendary (1% spawn rate):**
11. Supreme Predator - Massive damage multiplier
12. Meow Mix - Combines multiple weapon effects

---

## 🎮 How to Play

1. Open project in Godot 4.5+
2. Run scenes/main.tscn (F5)
3. Move with WASD or controller left stick
4. Player automatically attacks nearby enemies
5. Collect cat food (yellow spheres) to fill hunger bar
6. When hunger bar fills, choose powerups from level-up screen
7. Use Skip, Banish, or Reroll options strategically
8. Survive as long as possible!

---

## 🔜 Next Steps

### Phase 1 Enhancement: Weapon System
Before moving to Phase 2, we should implement:
- **8 cat-themed weapons** with unique mechanics
- **Weapon selection at levels 6, 12, 18, 21**
- Integration with existing powerup system
- Character-specific starting weapons

### Phase 2: Menu & Character Systems
After weapons are complete:
- **Multiple playable cat characters** (each with unique starting weapon)
- Title screen with game start
- Difficulty selection
- Character selection UI with cat portraits
- Settings menu

This approach means Phase 2 character selection will be more meaningful, as each cat will have a distinct playstyle based on their starting weapon!
