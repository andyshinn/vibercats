extends Resource

class_name Powerup

## Powerup data resource for cat-themed abilities
## Defines rarity, effects, and metadata

enum Rarity {
	COMMON,      # 60% chance
	UNCOMMON,    # 25% chance
	RARE,        # 10% chance
	EPIC,        # 4% chance
	LEGENDARY    # 1% chance
}

enum PowerupType {
	WEAPON,
	MOVEMENT,
	DEFENSIVE,
	UTILITY
}

@export var powerup_id: String = ""
@export var powerup_name: String = ""
@export var description: String = ""
@export var rarity: Rarity = Rarity.COMMON
@export var type: PowerupType = PowerupType.WEAPON
@export var icon: Texture2D  # For UI display
@export var max_stack: int = 1  # How many times can this powerup be picked

# Effect values
@export var damage_bonus: float = 0.0
@export var attack_speed_bonus: float = 0.0
@export var move_speed_bonus: float = 0.0
@export var health_bonus: float = 0.0
@export var defense_bonus: float = 0.0
@export var xp_magnet_bonus: float = 0.0
@export var cooldown_reduction: float = 0.0

# Special effects (these would need custom implementation)
@export var grants_ability: String = ""  # Name of ability to grant
@export var custom_effect: String = ""  # Custom effect identifier

func get_rarity_name() -> String:
	match rarity:
		Rarity.COMMON: return "Common"
		Rarity.UNCOMMON: return "Uncommon"
		Rarity.RARE: return "Rare"
		Rarity.EPIC: return "Epic"
		Rarity.LEGENDARY: return "Legendary"
	return "Unknown"

func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.UNCOMMON: return Color.GREEN
		Rarity.RARE: return Color.BLUE
		Rarity.EPIC: return Color.PURPLE
		Rarity.LEGENDARY: return Color.ORANGE
	return Color.WHITE

func get_rarity_weight() -> float:
	match rarity:
		Rarity.COMMON: return 0.60
		Rarity.UNCOMMON: return 0.25
		Rarity.RARE: return 0.10
		Rarity.EPIC: return 0.04
		Rarity.LEGENDARY: return 0.01
	return 0.0
