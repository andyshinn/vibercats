extends Node

## Singleton managing all available weapons and weapon selection
## Autoloaded as "WeaponManager" - accessible globally throughout the game

## All available weapons in the game
var all_weapons: Array[Weapon] = []

## Levels at which weapon selection is offered
var weapon_unlock_levels: Array[int] = []

func _ready():
	# Wait for DataLoader to finish loading
	call_deferred("_initialize_weapons")

## Initialize weapons from JSON data
func _initialize_weapons():
	all_weapons.clear()

	# Load weapon unlock levels from JSON
	var unlock_levels = DataLoader.get_weapon_unlock_levels()
	weapon_unlock_levels.clear()
	for level in unlock_levels:
		weapon_unlock_levels.append(int(level))

	# Load weapons from JSON
	var weapons_json = DataLoader.get_weapons()

	for weapon_data in weapons_json:
		var weapon = Weapon.new()
		weapon.weapon_id = weapon_data.get("weapon_id", "")
		weapon.weapon_name = weapon_data.get("weapon_name", "")
		weapon.description = weapon_data.get("description", "")
		weapon.base_damage = weapon_data.get("base_damage", 10.0)
		weapon.base_cooldown = weapon_data.get("base_cooldown", 1.0)
		weapon.base_range = weapon_data.get("base_range", 3.0)
		weapon.base_projectile_speed = weapon_data.get("base_projectile_speed", 5.0)

		# Convert weapon type string to enum
		var weapon_type_str = weapon_data.get("weapon_type", "MELEE")
		weapon.weapon_type = DataLoader.string_to_weapon_type(weapon_type_str)

		all_weapons.append(weapon)

	print("WeaponManager initialized with ", all_weapons.size(), " weapons from JSON")

## Check if the current level should offer weapon selection
func should_offer_weapon_selection(level: int) -> bool:
	return level in weapon_unlock_levels

## Get a random selection of N weapons (excluding already owned weapons)
## Returns up to count weapons, or fewer if not enough available
func get_random_weapon_choices(count: int, owned_weapon_ids: Array[String] = []) -> Array[Weapon]:
	var available_weapons = all_weapons.filter(func(w): return w.weapon_id not in owned_weapon_ids)

	if available_weapons.is_empty():
		return []

	# Shuffle and take first 'count' items
	available_weapons.shuffle()
	var choices: Array[Weapon] = []
	for i in range(min(count, available_weapons.size())):
		choices.append(available_weapons[i])

	return choices

## Get weapon by ID
func get_weapon_by_id(weapon_id: String) -> Weapon:
	for weapon in all_weapons:
		if weapon.weapon_id == weapon_id:
			return weapon.duplicate_weapon()
	return null

## Get all weapons (for debugging/testing)
func get_all_weapons() -> Array[Weapon]:
	return all_weapons.duplicate()
