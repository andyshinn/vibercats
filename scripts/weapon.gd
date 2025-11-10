extends Resource
class_name Weapon

## Represents a cat-themed weapon with unique attack patterns
## Used by WeaponManager to track available weapons and by Player to execute attacks

## Weapon identification
@export var weapon_id: String = ""
@export var weapon_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null

## Weapon stats
@export var base_damage: float = 10.0
@export var base_cooldown: float = 1.0  # Seconds between attacks
@export var base_range: float = 3.0     # Attack range
@export var base_projectile_speed: float = 5.0  # For ranged weapons

## Weapon type determines attack pattern behavior
enum WeaponType {
	MELEE,           # Direct damage to nearby enemies
	PROJECTILE,      # Shoots projectiles
	AREA,            # Area-of-effect damage
	SUMMON,          # Spawns turrets or persistent effects
	BEAM,            # Continuous damage beam
}

@export var weapon_type: WeaponType = WeaponType.MELEE

## Scene to instantiate for weapon effects (projectiles, beams, etc.)
@export var effect_scene: PackedScene = null

## Current upgrade level (can be increased through powerups)
var upgrade_level: int = 0

## Applied stat modifiers from powerups
var damage_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0
var range_multiplier: float = 1.0

## Computed properties
func get_damage() -> float:
	return base_damage * damage_multiplier * (1.0 + upgrade_level * 0.2)

func get_cooldown() -> float:
	return base_cooldown * cooldown_multiplier / (1.0 + upgrade_level * 0.1)

func get_range() -> float:
	return base_range * range_multiplier * (1.0 + upgrade_level * 0.15)

func get_projectile_speed() -> float:
	return base_projectile_speed * (1.0 + upgrade_level * 0.1)

## Upgrade the weapon (called when powerups enhance this weapon)
func upgrade():
	upgrade_level += 1

## Create a deep copy of this weapon for instance-specific modifications
func duplicate_weapon() -> Weapon:
	var copy = duplicate() as Weapon
	copy.upgrade_level = 0
	copy.damage_multiplier = 1.0
	copy.cooldown_multiplier = 1.0
	copy.range_multiplier = 1.0
	return copy
