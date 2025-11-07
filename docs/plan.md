# Viber Cats - Isometric Survivors-like Game

## Project Overview
A cat-themed Survivors-like game similar to Vampire Survivors, Spell Brigade, and Deep Rock Galactic: Survivors, built in Godot 4.5 with an isometric perspective. The player controls a heroic cat defending against waves of enemies using cat-themed weapons and abilities.

## Implementation Plan

### Phase 1: Core Gameplay (Current Focus)

#### 1. Main Game Scene
- 3D scene with isometric camera view (tilted 45° angle)
- Camera follows player and keeps them centered on screen
- Camera pans smoothly as player moves
- Static map with ground plane
- Collidable environmental objects (trees, rocks, etc.)
- Player and enemies must navigate around obstacles
- Single main map for initial implementation

#### 2. Player System (Cat Character)
- WASD + controller movement support
- Health system with health bar UI (represented as cat lives/health)
- Automated cat-themed attacks that target nearest enemy

#### 3. Enemy System
- Off-screen spawner that continuously generates enemies
- AI that follows the player using pathfinding
- Enemies navigate around obstacles (trees, rocks, etc.)
- Health bars above enemies
- Cat food drops on death (serves as XP)

#### 4. Progression & Powerup System
- Cat food collection with magnetic pickup (acts as XP)
- Hunger bar (XP bar) UI that fills up to trigger level-up
- Level-up pauses game and shows powerup selection screen
- Cat-themed powerup system with rarity tiers (Common, Uncommon, Rare, Epic, Legendary)
- Weighted random selection based on rarity
- Multiple powerup choices presented on level-up (3-4 options)
- Level-up meta-options:
  - **Skip**: Skip this level-up (useful when already strong)
  - **Banish**: Remove a powerup from the pool permanently this run
  - **Reroll**: Reroll the current powerup choices

### Phase 2: Menu & Selection Systems (Later)

#### 5. Title Screen
- Game start option
- Basic menu navigation
- Built using Godot's GUI system (Control nodes, Buttons, Labels, etc.)
- Multiplayer options (Host, Join, Local Co-op)

#### 6. Difficulty Selection
- Multiple difficulty levels
- Difficulty modifiers (enemy speed, spawn rate, etc.)
- GUI-based selection interface

#### 7. Character Selection
- Character selection UI
- System designed for future character expansion
- GUI-based character cards and selection
- Support for multiple player character selections in multiplayer

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
