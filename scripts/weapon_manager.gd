extends Node

## Singleton managing all available weapons and weapon selection
## Autoloaded as "WeaponManager" - accessible globally throughout the game

## Signal emitted when a weapon is unlocked
signal weapon_unlocked(weapon: Weapon)

## All available weapons in the game
var all_weapons: Array[Weapon] = []

## Levels at which weapon selection is offered
const WEAPON_UNLOCK_LEVELS: Array[int] = [6, 12, 18, 21]

func _ready():
	_initialize_weapons()
	print("WeaponManager initialized with ", all_weapons.size(), " weapons")

## Initialize all 8 cat-themed weapons
func _initialize_weapons():
	all_weapons.clear()

	# 1. Claw Strike - Fast melee swipes
	var claw_strike = Weapon.new()
	claw_strike.weapon_id = "claw_strike"
	claw_strike.weapon_name = "Claw Strike"
	claw_strike.description = "Rapid melee swipes in front of the player. Fast and furious!"
	claw_strike.weapon_type = Weapon.WeaponType.MELEE
	claw_strike.base_damage = 15.0
	claw_strike.base_cooldown = 0.5
	claw_strike.base_range = 2.0
	all_weapons.append(claw_strike)

	# 2. Furball Launcher - Bouncing projectiles
	var furball_launcher = Weapon.new()
	furball_launcher.weapon_id = "furball_launcher"
	furball_launcher.weapon_name = "Furball Launcher"
	furball_launcher.description = "Shoots bouncing furballs that ricochet off walls."
	furball_launcher.weapon_type = Weapon.WeaponType.PROJECTILE
	furball_launcher.base_damage = 20.0
	furball_launcher.base_cooldown = 1.0
	furball_launcher.base_range = 10.0
	furball_launcher.base_projectile_speed = 8.0
	all_weapons.append(furball_launcher)

	# 3. Tail Whip - Spinning area attack
	var tail_whip = Weapon.new()
	tail_whip.weapon_id = "tail_whip"
	tail_whip.weapon_name = "Tail Whip"
	tail_whip.description = "Spins around dealing damage to all nearby enemies."
	tail_whip.weapon_type = Weapon.WeaponType.AREA
	tail_whip.base_damage = 25.0
	tail_whip.base_cooldown = 2.0
	tail_whip.base_range = 3.0
	all_weapons.append(tail_whip)

	# 4. Yarn Ball - Homing projectiles
	var yarn_ball = Weapon.new()
	yarn_ball.weapon_id = "yarn_ball"
	yarn_ball.weapon_name = "Yarn Ball"
	yarn_ball.description = "Launches yarn balls that seek out and chase enemies."
	yarn_ball.weapon_type = Weapon.WeaponType.PROJECTILE
	yarn_ball.base_damage = 18.0
	yarn_ball.base_cooldown = 1.5
	yarn_ball.base_range = 15.0
	yarn_ball.base_projectile_speed = 6.0
	all_weapons.append(yarn_ball)

	# 5. Catnip Bomb - AOE explosion
	var catnip_bomb = Weapon.new()
	catnip_bomb.weapon_id = "catnip_bomb"
	catnip_bomb.weapon_name = "Catnip Bomb"
	catnip_bomb.description = "Throws explosive catnip that deals area damage over time."
	catnip_bomb.weapon_type = Weapon.WeaponType.AREA
	catnip_bomb.base_damage = 30.0
	catnip_bomb.base_cooldown = 3.0
	catnip_bomb.base_range = 5.0
	all_weapons.append(catnip_bomb)

	# 6. Laser Pointer - Piercing beam
	var laser_pointer = Weapon.new()
	laser_pointer.weapon_id = "laser_pointer"
	laser_pointer.weapon_name = "Laser Pointer"
	laser_pointer.description = "Continuous beam that pierces through multiple enemies."
	laser_pointer.weapon_type = Weapon.WeaponType.BEAM
	laser_pointer.base_damage = 12.0
	laser_pointer.base_cooldown = 0.3
	laser_pointer.base_range = 12.0
	all_weapons.append(laser_pointer)

	# 7. Fish Slap - Knockback melee
	var fish_slap = Weapon.new()
	fish_slap.weapon_id = "fish_slap"
	fish_slap.weapon_name = "Fish Slap"
	fish_slap.description = "Slaps enemies with a fish, dealing damage and knockback."
	fish_slap.weapon_type = Weapon.WeaponType.MELEE
	fish_slap.base_damage = 22.0
	fish_slap.base_cooldown = 1.2
	fish_slap.base_range = 2.5
	all_weapons.append(fish_slap)

	# 8. Scratching Post - Auto-attack turret
	var scratching_post = Weapon.new()
	scratching_post.weapon_id = "scratching_post"
	scratching_post.weapon_name = "Scratching Post"
	scratching_post.description = "Places a stationary turret that automatically attacks nearby enemies."
	scratching_post.weapon_type = Weapon.WeaponType.SUMMON
	scratching_post.base_damage = 10.0
	scratching_post.base_cooldown = 8.0  # Time between placing turrets
	scratching_post.base_range = 8.0     # Turret attack range
	all_weapons.append(scratching_post)

## Check if the current level should offer weapon selection
func should_offer_weapon_selection(level: int) -> bool:
	return level in WEAPON_UNLOCK_LEVELS

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
