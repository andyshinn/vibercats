extends Node

## Powerup Manager Singleton
## Manages the powerup pool, selection, and rarity weighting

var all_powerups: Array[Powerup] = []
var available_powerups: Array[Powerup] = []  # Powerups not banished
var equipped_powerups: Dictionary = {}  # powerup_id -> stack_count

signal powerup_selected(powerup: Powerup)

func _ready():
	# Wait for DataLoader to finish loading
	call_deferred("_initialize_powerups")

func _initialize_powerups():
	all_powerups.clear()

	# Load powerups from JSON
	var powerups_json = DataLoader.get_powerups()

	for powerup_data in powerups_json:
		var powerup = Powerup.new()
		powerup.powerup_id = powerup_data.get("powerup_id", "")
		powerup.powerup_name = powerup_data.get("powerup_name", "")
		powerup.description = powerup_data.get("description", "")
		powerup.max_stack = powerup_data.get("max_stack", 1)

		# Convert rarity string to enum
		var rarity_string = powerup_data.get("rarity", "COMMON")
		powerup.rarity = DataLoader.string_to_rarity(rarity_string)

		# Convert type string to enum
		var powerup_type_str = powerup_data.get("type", "WEAPON")
		powerup.type = DataLoader.string_to_powerup_type(powerup_type_str)

		# Load effect values
		powerup.damage_bonus = powerup_data.get("damage_bonus", 0.0)
		powerup.attack_speed_bonus = powerup_data.get("attack_speed_bonus", 0.0)
		powerup.move_speed_bonus = powerup_data.get("move_speed_bonus", 0.0)
		powerup.health_bonus = powerup_data.get("health_bonus", 0.0)
		powerup.defense_bonus = powerup_data.get("defense_bonus", 0.0)
		powerup.xp_magnet_bonus = powerup_data.get("xp_magnet_bonus", 0.0)
		powerup.cooldown_reduction = powerup_data.get("cooldown_reduction", 0.0)

		# Load special effects
		powerup.grants_ability = powerup_data.get("grants_ability", "")
		powerup.custom_effect = powerup_data.get("custom_effect", "")

		all_powerups.append(powerup)

	available_powerups = all_powerups.duplicate()
	print("PowerupManager initialized with ", all_powerups.size(), " powerups from JSON")

func get_random_powerups(count: int = 3) -> Array[Powerup]:
	var selected: Array[Powerup] = []
	var candidates = available_powerups.duplicate()

	# Remove powerups that are already at max stack
	candidates = candidates.filter(func(p):
		if not equipped_powerups.has(p.powerup_id):
			return true
		return equipped_powerups[p.powerup_id] < p.max_stack
	)

	if candidates.is_empty():
		return selected

	# Create weighted pool based on rarity
	var weighted_pool: Array[Powerup] = []
	for powerup in candidates:
		var weight = powerup.get_rarity_weight()
		var copies = int(weight * 100)  # Convert to integer count
		for i in range(copies):
			weighted_pool.append(powerup)

	# Randomly select unique powerups
	var selected_ids: Array[String] = []
	while selected.size() < count and not weighted_pool.is_empty():
		var random_powerup = weighted_pool[randi() % weighted_pool.size()]

		if not selected_ids.has(random_powerup.powerup_id):
			selected.append(random_powerup)
			selected_ids.append(random_powerup.powerup_id)

		# Remove all copies of this powerup from pool to avoid duplicates
		weighted_pool = weighted_pool.filter(func(p): return p.powerup_id != random_powerup.powerup_id)

	return selected

func equip_powerup(powerup: Powerup):
	if equipped_powerups.has(powerup.powerup_id):
		equipped_powerups[powerup.powerup_id] += 1
	else:
		equipped_powerups[powerup.powerup_id] = 1

	powerup_selected.emit(powerup)

func banish_powerup(powerup: Powerup):
	available_powerups = available_powerups.filter(func(p): return p.powerup_id != powerup.powerup_id)

func reset():
	equipped_powerups.clear()
	available_powerups = all_powerups.duplicate()
