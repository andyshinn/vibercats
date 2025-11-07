# Viber Cats - Setup Instructions

This document provides step-by-step instructions for setting up the game scenes in Godot.

## Prerequisites

1. Install **Kenny Starter Kit (Basic Scene)** from AssetLib in Godot
   - Open Godot Editor
   - Go to AssetLib tab
   - Search for "Starter Kit Basic Scene"
   - Download and install

## Scene Setup

### 1. Player Scene (scenes/player.tscn)

Create a new scene with the following structure:

```
Player (CharacterBody3D)
├── CollisionShape3D
│   └── Shape: CapsuleShape3D (height: 2, radius: 0.5)
├── MeshInstance3D
│   └── Mesh: CapsuleMesh (height: 2, radius: 0.5)
│   └── Material: Set to a color (e.g., orange for cat)
└── Camera3DPivot (Node3D) - for later camera attachment
```

**Script:** Attach `res://scripts/player.gd`

**Groups:** Add to group "players"

**Properties to set:**
- Move Speed: 5.0
- Max Health: 100.0
- Attack Range: 5.0

### 2. Enemy Scene (scenes/enemy.tscn)

Create a new scene with the following structure:

```
Enemy (CharacterBody3D)
├── CollisionShape3D
│   └── Shape: BoxShape3D (size: 1, 1, 1)
├── MeshInstance3D
│   └── Mesh: BoxMesh (size: 1, 1, 1)
│   └── Material: Set to a color (e.g., red for enemy)
└── NavigationAgent3D
    └── Path Desired Distance: 0.5
    └── Target Desired Distance: 0.5
```

**Script:** Attach `res://scripts/enemy.gd`

**Properties to set:**
- Move Speed: 3.0
- Max Health: 50.0
- Attack Range: 1.5

### 3. Cat Food Scene (scenes/cat_food.tscn)

Create a new scene with the following structure:

```
CatFood (Area3D)
├── CollisionShape3D
│   └── Shape: SphereShape3D (radius: 0.3)
└── MeshInstance3D
    └── Mesh: SphereMesh (radius: 0.3, height: 0.6)
    └── Material: Set to a color (e.g., yellow/gold)
```

**Script:** Attach `res://scripts/cat_food.gd`

**Properties to set:**
- XP Value: 1
- Magnet Range: 5.0
- Move Speed: 10.0

**Collision:** Set Layer and Mask appropriately for Area3D

### 4. Main Game Scene (scenes/main.tscn)

Create a new 3D scene with the following structure:

```
Main (Node3D)
├── DirectionalLight3D
│   └── Rotation: (-45, -30, 0) for nice lighting
│   └── Shadow Enabled: true
├── WorldEnvironment
│   └── Environment: Create new Environment
├── Ground (StaticBody3D)
│   ├── CollisionShape3D
│   │   └── Shape: BoxShape3D (size: 100, 0.2, 100)
│   └── MeshInstance3D
│       └── Mesh: BoxMesh (size: 100, 0.2, 100)
│       └── Material: StandardMaterial3D (set a ground color)
├── NavigationRegion3D
│   └── (This will contain the navigation mesh - bake after adding obstacles)
├── Camera3D
│   └── Position: (0, 20, 15)
│   └── Rotation: (-50, 0, 0) for isometric view
│   └── Projection: Perspective
│   └── Add script for camera follow (see below)
├── Player (Instance of scenes/player.tscn)
│   └── Position: (0, 1, 0)
└── EnemySpawner (Node3D)
    └── Script: res://scripts/enemy_spawner.gd
    └── Enemy Scene: Set to res://scenes/enemy.tscn
    └── Spawn Interval: 2.0
    └── Spawn Distance: 20.0
```

### 5. Camera Follow Script

Create `scripts/camera_follow.gd`:

```gdscript
extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 20, 15)
@export var smoothing: float = 5.0

func _ready():
	if not target:
		var players = get_tree().get_nodes_in_group("players")
		if players.size() > 0:
			target = players[0]

func _process(delta: float):
	if target and is_instance_valid(target):
		var target_position = target.global_position + offset
		global_position = global_position.lerp(target_position, smoothing * delta)
```

Attach this script to the Camera3D in the main scene.

### 6. Adding Obstacles (Trees and Rocks)

Using Kenny Starter Kit assets, create obstacle scenes:

**Tree Scene (scenes/environment/tree.tscn):**
```
Tree (StaticBody3D)
├── CollisionShape3D
│   └── Shape: CylinderShape3D (radius: 0.5, height: 3)
└── MeshInstance3D (from Kenny assets)
```

**Rock Scene (scenes/environment/rock.tscn):**
```
Rock (StaticBody3D)
├── CollisionShape3D
│   └── Shape: SphereShape3D or BoxShape3D
└── MeshInstance3D (from Kenny assets)
```

Place multiple instances of trees and rocks in the Main scene as children of the NavigationRegion3D parent node.

### 7. Baking Navigation

1. Select the NavigationRegion3D node
2. In the inspector, click "Bake NavigationMesh"
3. This creates a navigation mesh that enemies will use for pathfinding

### 8. HUD Scene (scenes/ui/hud.tscn)

Create a new scene with CanvasLayer as root:

```
HUD (CanvasLayer)
└── MarginContainer
    └── Custom Minimum Size: Leave default
    └── Anchors: Full Rect
    └── Margins: Left: 20, Top: 20, Right: -20, Bottom: -20
    └── VBoxContainer
        ├── LevelLabel (Label)
        │   └── Text: "Level: 1"
        │   └── Theme Override Font Size: 24
        ├── HealthBar (ProgressBar)
        │   └── Custom Minimum Size: (300, 30)
        │   └── Max Value: 100
        │   └── Value: 100
        │   └── Show Percentage: false
        │   └── Theme Override: Set fill color to red
        └── HungerBar (ProgressBar)
            └── Custom Minimum Size: (300, 30)
            └── Max Value: 10
            └── Value: 0
            └── Show Percentage: false
            └── Theme Override: Set fill color to yellow/gold
```

**Script:** Attach `res://scripts/hud.gd`

**Add to Main Scene:** Instance the HUD scene in scenes/main.tscn as a child of the root node

### 9. Level-up Screen (scenes/ui/levelup_screen.tscn)

Create a new scene with Control as root:

```
LevelUpScreen (Control)
└── Anchors: Full Rect
└── Panel (Panel)
    └── Anchors: Center
    └── Custom Minimum Size: (800, 600)
    └── MarginContainer
        └── Margins: All 20
        └── VBoxContainer
            ├── LevelLabel (Label)
            │   └── Text: "Level Up!"
            │   └── Horizontal Alignment: Center
            │   └── Font Size: 32
            ├── PowerupContainer (HBoxContainer)
            │   └── Alignment: Center
            │   └── (Powerup choices will be added here dynamically)
            └── MetaOptions (HBoxContainer)
                └── Alignment: Center
                ├── SkipButton (Button)
                │   └── Text: "Skip"
                ├── RerollButton (Button)
                │   └── Text: "Reroll (3)"
```

**Script:** Attach `res://scripts/levelup_screen.gd`

**Groups:** Add to group "levelup_screen"

**Add to Main Scene:** Instance in scenes/main.tscn as a child of root

### 10. Powerup Choice (scenes/ui/powerup_choice.tscn)

Create a new scene with PanelContainer as root:

```
PowerupChoice (PanelContainer)
└── Custom Minimum Size: (200, 250)
└── MarginContainer
    └── Margins: All 10
    └── VBoxContainer
        ├── NameLabel (Label)
        │   └── Text: "Powerup Name"
        │   └── Horizontal Alignment: Center
        │   └── Font Size: 18
        ├── RarityLabel (Label)
        │   └── Text: "Common"
        │   └── Horizontal Alignment: Center
        ├── DescriptionLabel (Label)
        │   └── Text: "Description here"
        │   └── Autowrap Mode: Word
        ├── SelectButton (Button)
        │   └── Text: "Select"
        └── BanishButton (Button)
            └── Text: "Banish"
```

**Script:** Attach `res://scripts/powerup_choice.gd`

## Testing

1. Open `scenes/main.tscn`
2. Press F5 or click Run Project
3. Use WASD to move the player
4. Enemies should spawn and chase the player
5. Player should automatically attack nearby enemies
6. Cat food should drop and be collectable

## Notes

- Make sure all collision layers are properly configured
- The player should be on layer 1
- Enemies should be on layer 2
- Cat food should be on layer 3
- Ground and obstacles should be on layer 4

## Troubleshooting

**Enemies not moving:** Make sure NavigationRegion3D is baked and enemies have NavigationAgent3D node.

**Player can't move:** Check that input actions are configured in Project Settings.

**No cat food spawning:** Make sure the enemy script has the cat_food scene path set correctly.
