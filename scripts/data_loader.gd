extends Node

## DataLoader Singleton
## Loads and validates JSON data files for weapons, powerups, and balance settings
## Autoloaded as "DataLoader"

## Cached data
var weapons_data: Dictionary = {}
var powerups_data: Dictionary = {}
var balance_data: Dictionary = {}
var characters_data: Dictionary = {}

## Data file paths
const WEAPONS_PATH = "res://data/weapons.json"
const POWERUPS_PATH = "res://data/powerups.json"
const BALANCE_PATH = "res://data/balance.json"
const CHARACTERS_PATH = "res://data/characters.json"

func _ready():
	load_all_data()

## Load all JSON data files
func load_all_data() -> bool:
	var success = true

	if not load_weapons():
		push_error("Failed to load weapons.json")
		success = false

	if not load_powerups():
		push_error("Failed to load powerups.json")
		success = false

	if not load_balance():
		push_error("Failed to load balance.json")
		success = false

	if not load_characters():
		push_error("Failed to load characters.json")
		success = false

	if success:
		print("DataLoader: All data files loaded successfully")

	return success

## Load weapons.json
func load_weapons() -> bool:
	weapons_data = _load_json_file(WEAPONS_PATH)
	if weapons_data.is_empty():
		return false

	# Validate structure
	if not weapons_data.has("weapons") or not weapons_data["weapons"] is Array:
		push_error("Invalid weapons.json structure: missing 'weapons' array")
		return false

	print("DataLoader: Loaded ", weapons_data["weapons"].size(), " weapons")
	return true

## Load powerups.json
func load_powerups() -> bool:
	powerups_data = _load_json_file(POWERUPS_PATH)
	if powerups_data.is_empty():
		return false

	# Validate structure
	if not powerups_data.has("powerups") or not powerups_data["powerups"] is Array:
		push_error("Invalid powerups.json structure: missing 'powerups' array")
		return false

	print("DataLoader: Loaded ", powerups_data["powerups"].size(), " powerups")
	return true

## Load balance.json
func load_balance() -> bool:
	balance_data = _load_json_file(BALANCE_PATH)
	if balance_data.is_empty():
		return false

	print("DataLoader: Loaded balance data")
	return true

## Load characters.json
func load_characters() -> bool:
	characters_data = _load_json_file(CHARACTERS_PATH)
	if characters_data.is_empty():
		return false

	# Validate structure
	if not characters_data.has("characters") or not characters_data["characters"] is Array:
		push_error("Invalid characters.json structure: missing 'characters' array")
		return false

	print("DataLoader: Loaded ", characters_data["characters"].size(), " characters")
	return true

## Get all weapons from JSON
func get_weapons() -> Array:
	if weapons_data.has("weapons"):
		return weapons_data["weapons"]
	return []

## Get weapon unlock levels
func get_weapon_unlock_levels() -> Array:
	if weapons_data.has("weapon_unlock_levels"):
		return weapons_data["weapon_unlock_levels"]
	return []

## Get all powerups from JSON
func get_powerups() -> Array:
	if powerups_data.has("powerups"):
		return powerups_data["powerups"]
	return []

## Get rarity weights
func get_rarity_weights() -> Dictionary:
	if powerups_data.has("rarity_weights"):
		return powerups_data["rarity_weights"]
	return {}

## Get balance value by path (e.g., "player.base_health")
func get_balance(path: String, default_value = null):
	var keys = path.split(".")
	var current = balance_data

	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return default_value

	return current

## Get all balance data
func get_all_balance() -> Dictionary:
	return balance_data

## Get all characters from JSON
func get_characters() -> Array:
	if characters_data.has("characters"):
		return characters_data["characters"]
	return []

## Get default character ID
func get_default_character() -> String:
	if characters_data.has("default_character"):
		return characters_data["default_character"]
	return ""

## Internal: Load a JSON file and return parsed Dictionary
func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("DataLoader: File not found: " + path)
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("DataLoader: Cannot open file: " + path)
		return {}

	var content = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(content)

	if parse_result != OK:
		push_error("DataLoader: JSON parse error in " + path + " at line " + str(json.get_error_line()) + ": " + json.get_error_message())
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		push_error("DataLoader: Invalid JSON format in " + path + " - expected Dictionary")
		return {}

	return data

## Convert string to Weapon.WeaponType enum
func string_to_weapon_type(weapon_type_string: String) -> int:
	match weapon_type_string.to_upper():
		"MELEE": return 0  # Weapon.WeaponType.MELEE
		"PROJECTILE": return 1  # Weapon.WeaponType.PROJECTILE
		"AREA": return 2  # Weapon.WeaponType.AREA
		"SUMMON": return 3  # Weapon.WeaponType.SUMMON
		"BEAM": return 4  # Weapon.WeaponType.BEAM
		_:
			push_error("Unknown weapon type: " + weapon_type_string)
			return 0

## Convert string to Powerup.Rarity enum
func string_to_rarity(rarity_string: String) -> int:
	match rarity_string.to_upper():
		"COMMON": return 0  # Powerup.Rarity.COMMON
		"UNCOMMON": return 1  # Powerup.Rarity.UNCOMMON
		"RARE": return 2  # Powerup.Rarity.RARE
		"EPIC": return 3  # Powerup.Rarity.EPIC
		"LEGENDARY": return 4  # Powerup.Rarity.LEGENDARY
		_:
			push_error("Unknown rarity: " + rarity_string)
			return 0

## Convert string to Powerup.PowerupType enum
func string_to_powerup_type(powerup_type_string: String) -> int:
	match powerup_type_string.to_upper():
		"WEAPON": return 0  # Powerup.PowerupType.WEAPON
		"MOVEMENT": return 1  # Powerup.PowerupType.MOVEMENT
		"DEFENSIVE": return 2  # Powerup.PowerupType.DEFENSIVE
		"UTILITY": return 3  # Powerup.PowerupType.UTILITY
		_:
			push_error("Unknown powerup type: " + powerup_type_string)
			return 0
