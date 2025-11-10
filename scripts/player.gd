extends CharacterBody3D

class_name Player

## Player character controller for Viber Cats
## Handles movement, combat, and input for the cat character

@export var move_speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0

# Health
@export var max_health: float = 100.0
var current_health: float = 100.0

# Combat (legacy - will be replaced by weapons)
@export var attack_damage: float = 10.0
@export var attack_range: float = 5.0
@export var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

# Weapons System
var equipped_weapons: Array[Weapon] = []
var weapon_cooldowns: Dictionary = {}  # weapon_id -> cooldown_timer

# References
var nearest_enemy: Node3D = null

# Signals
signal health_changed(new_health: float, max_health: float)
signal died()
signal weapon_equipped(weapon: Weapon)

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)

	# Connect to level-up screen for weapon selection
	var levelup_screen = get_tree().get_first_node_in_group("levelup_screen")
	if levelup_screen and levelup_screen.has_signal("weapon_chosen"):
		levelup_screen.weapon_chosen.connect(_on_weapon_chosen)

func _physics_process(delta: float):
	handle_movement(delta)
	handle_combat(delta)
	handle_debug_input()
	move_and_slide()

func handle_movement(delta: float):
	# Get input direction from left stick or WASD
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Also check right stick (allow either stick for movement)
	var right_stick = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Debug: Print stick values every 60 frames
	if Engine.get_process_frames() % 60 == 0:
		print("Left stick: (%.2f, %.2f) mag=%.2f | Right stick: (%.2f, %.2f) mag=%.2f" % [
			input_dir.x, input_dir.y, input_dir.length(),
			right_stick.x, right_stick.y, right_stick.length()
		])

	# Use whichever stick has more deflection
	if right_stick.length() > input_dir.length():
		input_dir = right_stick

	# Get the raw magnitude before normalizing (for proportional speed)
	var input_magnitude = min(input_dir.length(), 1.0)  # Clamp to max 1.0

	# Get direction (normalized)
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	if direction.length() > 0:
		direction = direction.normalized()

	if input_magnitude > 0.01:  # Small deadzone
		# Speed is proportional to stick deflection
		# Full deflection = full speed, half deflection = half speed
		var target_speed = move_speed * input_magnitude
		var target_velocity = direction * target_speed

		# Debug: Print target speed
		if Engine.get_process_frames() % 60 == 0:
			print("Input magnitude: %.2f | Target speed: %.2f | Actual velocity: (%.2f, %.2f)" % [
				input_magnitude, target_speed, velocity.x, velocity.z
			])

		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta

func handle_combat(delta: float):
	# Update weapon cooldowns
	for weapon_id in weapon_cooldowns.keys():
		weapon_cooldowns[weapon_id] -= delta

	# Update legacy attack timer
	if attack_timer > 0:
		attack_timer -= delta

	# Find nearest enemy
	nearest_enemy = find_nearest_enemy()

	# Use weapons if equipped, otherwise fall back to basic attack
	if equipped_weapons.size() > 0:
		execute_weapon_attacks()
	elif nearest_enemy and global_position.distance_to(nearest_enemy.global_position) <= attack_range:
		if attack_timer <= 0:
			perform_attack()
			attack_timer = attack_cooldown

func find_nearest_enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node3D = null
	var closest_distance: float = INF

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = enemy

	return closest

func perform_attack():
	if not nearest_enemy or not is_instance_valid(nearest_enemy):
		return

	# Deal damage to enemy
	if nearest_enemy.has_method("take_damage"):
		nearest_enemy.take_damage(attack_damage)

func take_damage(amount: float):
	current_health -= amount
	current_health = max(0, current_health)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

func heal(amount: float):
	current_health += amount
	current_health = min(max_health, current_health)
	health_changed.emit(current_health, max_health)

func die():
	died.emit()
	# Game over logic will be handled by game manager
	queue_free()

func handle_debug_input():
	# Debug: Kill all enemies with Q key
	if Input.is_action_just_pressed("debug_kill_enemies"):
		var enemies = get_tree().get_nodes_in_group("enemies")
		print("DEBUG: Killing ", enemies.size(), " enemies")
		for enemy in enemies:
			if is_instance_valid(enemy):
				enemy.queue_free()

## Weapon System Methods

func equip_weapon(weapon: Weapon):
	"""Add a weapon to the player's arsenal"""
	if not weapon:
		push_error("Attempted to equip null weapon")
		return

	# Create a copy to avoid modifying the original
	var weapon_copy = weapon.duplicate_weapon()
	equipped_weapons.append(weapon_copy)
	weapon_cooldowns[weapon_copy.weapon_id] = 0.0

	print("Equipped weapon: ", weapon_copy.weapon_name)
	weapon_equipped.emit(weapon_copy)

func get_owned_weapon_ids() -> Array[String]:
	"""Returns list of weapon IDs the player owns"""
	var ids: Array[String] = []
	for weapon in equipped_weapons:
		ids.append(weapon.weapon_id)
	return ids

func execute_weapon_attacks():
	"""Execute attacks for all equipped weapons that are off cooldown"""
	for weapon in equipped_weapons:
		# Check cooldown
		if weapon_cooldowns.get(weapon.weapon_id, 0.0) > 0:
			continue

		# Execute weapon-specific attack
		match weapon.weapon_type:
			Weapon.WeaponType.MELEE:
				execute_melee_attack(weapon)
			Weapon.WeaponType.PROJECTILE:
				execute_projectile_attack(weapon)
			Weapon.WeaponType.AREA:
				execute_area_attack(weapon)
			Weapon.WeaponType.BEAM:
				execute_beam_attack(weapon)
			Weapon.WeaponType.SUMMON:
				execute_summon_attack(weapon)

		# Reset cooldown
		weapon_cooldowns[weapon.weapon_id] = weapon.get_cooldown()

func execute_melee_attack(weapon: Weapon):
	"""Melee weapons damage nearby enemies"""
	if not nearest_enemy:
		return

	var distance = global_position.distance_to(nearest_enemy.global_position)
	if distance <= weapon.get_range():
		if nearest_enemy.has_method("take_damage"):
			nearest_enemy.take_damage(weapon.get_damage())
			print(weapon.weapon_name, " hit for ", weapon.get_damage(), " damage!")

func execute_projectile_attack(weapon: Weapon):
	"""Projectile weapons shoot at enemies (placeholder - needs projectile scenes)"""
	if not nearest_enemy:
		return

	print(weapon.weapon_name, " fired projectile! (Not yet implemented)")
	# TODO: Instantiate projectile scene and send it toward enemy

func execute_area_attack(weapon: Weapon):
	"""Area weapons damage all enemies in range"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	var hit_count = 0

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var distance = global_position.distance_to(enemy.global_position)
		if distance <= weapon.get_range():
			if enemy.has_method("take_damage"):
				enemy.take_damage(weapon.get_damage())
				hit_count += 1

	if hit_count > 0:
		print(weapon.weapon_name, " hit ", hit_count, " enemies!")

func execute_beam_attack(weapon: Weapon):
	"""Beam weapons pierce through multiple enemies (placeholder)"""
	if not nearest_enemy:
		return

	print(weapon.weapon_name, " fired beam! (Not yet implemented)")
	# TODO: Raycast to hit multiple enemies in a line

func execute_summon_attack(weapon: Weapon):
	"""Summon weapons place turrets or persistent effects (placeholder)"""
	print(weapon.weapon_name, " placed turret! (Not yet implemented)")
	# TODO: Instantiate turret scene

func _on_weapon_chosen(weapon: Weapon):
	"""Called when player selects a weapon from level-up screen"""
	equip_weapon(weapon)
	print("Player chose weapon: ", weapon.weapon_name)
