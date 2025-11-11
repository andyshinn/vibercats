extends Resource
class_name Character

## Represents a playable cat character with unique stats and starting weapon
## Used by CharacterManager to track available characters and by Player to set character attributes

## Character identification
@export var character_id: String = ""
@export var character_name: String = ""
@export var description: String = ""
@export var flavor_text: String = ""

## Visual representation
@export var texture_path: String = ""
@export var texture: Texture2D = null

## Starting weapon
@export var starting_weapon_id: String = ""

## Character stats
@export var base_health: float = 100.0
@export var base_speed: float = 5.0

## Create a duplicate of this character
func duplicate_character() -> Character:
	var copy = duplicate() as Character
	return copy
