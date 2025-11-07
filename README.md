# Viber Cats

A cat-themed survivors-like game built in Godot 4.5 with an isometric perspective.

## Project Status

✅ **Phase 1 Scripts Complete** - All 12 core gameplay scripts implemented!
✅ **Phase 1 Scenes Complete** - All 9 essential scenes created!
⚠️ **Navigation Mesh** - Needs to be baked in Godot Editor before testing
📋 **Phase 2** - Menu systems (planned)
📋 **Phase 3** - Multiplayer (planned)

## Quick Start

### Prerequisites

- Godot 4.5+
- Kenny Starter Kit (Basic Scene) from AssetLib

### Setup

1. Open project in Godot Editor
2. Open `scenes/main.tscn`
3. Select the `NavigationRegion3D` node in the scene tree
4. Look for **"Bake NavMesh"** button in the **top toolbar** (appears when NavigationRegion3D is selected)
5. Click the "Bake NavMesh" button to generate the navigation mesh
6. Save the scene (Ctrl+S)
7. Run the game (F5)

**Note:** All scenes are already created! The NavigationMesh resource is assigned. You just need to bake it by clicking the button in the top toolbar.

## Game Features

- **Cat Player Character** with WASD/controller movement
- **Enemies** that spawn and chase using pathfinding
- **Automated Combat** - cat attacks nearest enemy
- **Cat Food Collection** - magnetic XP orbs
- **Level-up System** with hunger bar
- **12 Cat-Themed Powerups** (Common → Legendary)
  - Claw Swipe, Furball Projectiles, Nine Lives, Laser Pointer, and more!
- **Powerup Selection Screen** with Skip, Banish, and Reroll options
- **Rarity-based Powerup System** with weighted selection

## Documentation

- **[docs/plan.md](docs/plan.md)** - Full implementation plan
- **[docs/scenes_created.md](docs/scenes_created.md)** - All created scenes (complete!)
- **[docs/implementation_summary.md](docs/implementation_summary.md)** - Implementation details
- **[docs/setup_instructions.md](docs/setup_instructions.md)** - Manual scene setup guide (not needed!)

## Controls

- **WASD** or **Left Stick** - Move
- **Auto-attack** - Automatically attacks nearest enemy

## Architecture

### Core Systems

- **Player System** - Movement, health, combat
- **Enemy System** - AI pathfinding, spawning, difficulty scaling
- **Progression System** - XP collection, leveling, powerups
- **UI System** - HUD, level-up screen, powerup selection

### Autoload Singletons

- **PlayerStats** - Tracks XP, level, hunger bar
- **PowerupManager** - Manages powerup pool and selection

## File Structure

```
vibercats/
├── docs/           # Documentation
├── scripts/        # All GDScript files (12 files ✅)
├── scenes/         # Godot scene files (9 scenes ✅)
│   ├── main.tscn
│   ├── player.tscn
│   ├── enemy.tscn
│   ├── cat_food.tscn
│   ├── environment/ (tree, rock)
│   └── ui/ (hud, levelup_screen, powerup_choice)
└── project.godot   # Project configuration
```

## Cat-Themed Powerups

### Common (60%)
- Claw Swipe, Cat Reflexes, Curious Cat

### Uncommon (25%)
- Furball Projectiles, Purrfect Timing, Nine Lives

### Rare (10%)
- Tail Whip, Catnap

### Epic (4%)
- Laser Pointer, Catnip Cloud

### Legendary (1%)
- Supreme Predator, Meow Mix

## Development Roadmap

### Phase 1: Core Gameplay (Nearly Complete!)
- ✅ Player movement and combat
- ✅ Enemy AI and spawning
- ✅ Cat food collection
- ✅ Level-up system
- ✅ Powerup system
- ✅ All 9 scenes created
- ✅ Static map with obstacles (4 trees, 3 rocks)
- ⚠️ Navigation mesh needs baking (in Godot Editor)

### Phase 2: Menu Systems
- Title screen
- Difficulty selection
- Character selection

### Phase 3: Multiplayer
- Local co-op (2 players)
- Steam integration
- Online multiplayer

## Technical Details

- **Engine:** Godot 4.5
- **Renderer:** Forward Plus
- **View:** 3D Isometric (45° camera angle)
- **Physics:** CharacterBody3D for player/enemies
- **Navigation:** NavigationAgent3D for pathfinding
- **UI:** Godot GUI system (Control nodes)

## License

[To be determined]

## Credits

- **Assets:** Kenny Starter Kit (placeholder)
- **Engine:** Godot Engine
- **Inspired by:** Vampire Survivors, Spell Brigade, Deep Rock Galactic: Survivors
