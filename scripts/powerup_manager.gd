extends Node

## Powerup Manager Singleton
## Manages the powerup pool, selection, and rarity weighting

var all_powerups: Array[Powerup] = []
var available_powerups: Array[Powerup] = []  # Powerups not banished
var equipped_powerups: Dictionary = {}  # powerup_id -> stack_count

signal powerup_selected(powerup: Powerup)

func _ready():
	_initialize_powerups()
	available_powerups = all_powerups.duplicate()

func _initialize_powerups():
	# Create default cat-themed powerups
	# This is a starting set - more can be added via resources

	# COMMON POWERUPS
	var claw_swipe = Powerup.new()
	claw_swipe.powerup_id = "claw_swipe"
	claw_swipe.powerup_name = "Claw Swipe"
	claw_swipe.description = "Increases melee damage"
	claw_swipe.rarity = Powerup.Rarity.COMMON
	claw_swipe.type = Powerup.PowerupType.WEAPON
	claw_swipe.damage_bonus = 5.0
	claw_swipe.max_stack = 5
	all_powerups.append(claw_swipe)

	var cat_reflexes = Powerup.new()
	cat_reflexes.powerup_id = "cat_reflexes"
	cat_reflexes.powerup_name = "Cat Reflexes"
	cat_reflexes.description = "Increases movement speed"
	cat_reflexes.rarity = Powerup.Rarity.COMMON
	cat_reflexes.type = Powerup.PowerupType.MOVEMENT
	cat_reflexes.move_speed_bonus = 0.5
	cat_reflexes.max_stack = 5
	all_powerups.append(cat_reflexes)

	var curious_cat = Powerup.new()
	curious_cat.powerup_id = "curious_cat"
	curious_cat.powerup_name = "Curious Cat"
	curious_cat.description = "Increases cat food magnet range"
	curious_cat.rarity = Powerup.Rarity.COMMON
	curious_cat.type = Powerup.PowerupType.UTILITY
	curious_cat.xp_magnet_bonus = 2.0
	curious_cat.max_stack = 5
	all_powerups.append(curious_cat)

	# UNCOMMON POWERUPS
	var furball = Powerup.new()
	furball.powerup_id = "furball_projectiles"
	furball.powerup_name = "Furball Projectiles"
	furball.description = "Shoot ranged furball attacks"
	furball.rarity = Powerup.Rarity.UNCOMMON
	furball.type = Powerup.PowerupType.WEAPON
	furball.grants_ability = "furball_attack"
	furball.max_stack = 3
	all_powerups.append(furball)

	var purrfect_timing = Powerup.new()
	purrfect_timing.powerup_id = "purrfect_timing"
	purrfect_timing.powerup_name = "Purrfect Timing"
	purrfect_timing.description = "Reduces ability cooldowns"
	purrfect_timing.rarity = Powerup.Rarity.UNCOMMON
	purrfect_timing.type = Powerup.PowerupType.UTILITY
	purrfect_timing.cooldown_reduction = 0.1
	purrfect_timing.max_stack = 5
	all_powerups.append(purrfect_timing)

	var nine_lives = Powerup.new()
	nine_lives.powerup_id = "nine_lives"
	nine_lives.powerup_name = "Nine Lives"
	nine_lives.description = "Increases maximum health"
	nine_lives.rarity = Powerup.Rarity.UNCOMMON
	nine_lives.type = Powerup.PowerupType.DEFENSIVE
	nine_lives.health_bonus = 25.0
	nine_lives.max_stack = 9
	all_powerups.append(nine_lives)

	# RARE POWERUPS
	var tail_whip = Powerup.new()
	tail_whip.powerup_id = "tail_whip"
	tail_whip.powerup_name = "Tail Whip"
	tail_whip.description = "Area attack around the player"
	tail_whip.rarity = Powerup.Rarity.RARE
	tail_whip.type = Powerup.PowerupType.WEAPON
	tail_whip.grants_ability = "tail_whip_attack"
	tail_whip.max_stack = 3
	all_powerups.append(tail_whip)

	var catnap = Powerup.new()
	catnap.powerup_id = "catnap"
	catnap.powerup_name = "Catnap"
	catnap.description = "Regenerate health over time"
	catnap.rarity = Powerup.Rarity.RARE
	catnap.type = Powerup.PowerupType.DEFENSIVE
	catnap.grants_ability = "health_regen"
	catnap.max_stack = 5
	all_powerups.append(catnap)

	# EPIC POWERUPS
	var laser_pointer = Powerup.new()
	laser_pointer.powerup_id = "laser_pointer"
	laser_pointer.powerup_name = "Laser Pointer"
	laser_pointer.description = "Piercing beam attack"
	laser_pointer.rarity = Powerup.Rarity.EPIC
	laser_pointer.type = Powerup.PowerupType.WEAPON
	laser_pointer.grants_ability = "laser_beam"
	laser_pointer.max_stack = 1
	all_powerups.append(laser_pointer)

	var catnip_cloud = Powerup.new()
	catnip_cloud.powerup_id = "catnip_cloud"
	catnip_cloud.powerup_name = "Catnip Cloud"
	catnip_cloud.description = "Damage aura around player"
	catnip_cloud.rarity = Powerup.Rarity.EPIC
	catnip_cloud.type = Powerup.PowerupType.WEAPON
	catnip_cloud.grants_ability = "damage_aura"
	catnip_cloud.max_stack = 3
	all_powerups.append(catnip_cloud)

	# LEGENDARY POWERUPS
	var supreme_predator = Powerup.new()
	supreme_predator.powerup_id = "supreme_predator"
	supreme_predator.powerup_name = "Supreme Predator"
	supreme_predator.description = "Massive damage boost to all attacks"
	supreme_predator.rarity = Powerup.Rarity.LEGENDARY
	supreme_predator.type = Powerup.PowerupType.WEAPON
	supreme_predator.damage_bonus = 50.0
	supreme_predator.max_stack = 1
	all_powerups.append(supreme_predator)

	var meow_mix = Powerup.new()
	meow_mix.powerup_id = "meow_mix"
	meow_mix.powerup_name = "Meow Mix"
	meow_mix.description = "Combines multiple weapon effects"
	meow_mix.rarity = Powerup.Rarity.LEGENDARY
	meow_mix.type = Powerup.PowerupType.WEAPON
	meow_mix.custom_effect = "combo_attacks"
	meow_mix.max_stack = 1
	all_powerups.append(meow_mix)

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
