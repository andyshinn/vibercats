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

# Combat
@export var attack_damage: float = 10.0
@export var attack_range: float = 5.0
@export var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

# References
var nearest_enemy: Node3D = null

# Signals
signal health_changed(new_health: float, max_health: float)
signal died()

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)

func _physics_process(delta: float):
	handle_movement(delta)
	handle_combat(delta)
	move_and_slide()

func handle_movement(delta: float):
	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Convert 2D input to 3D direction (accounting for isometric view)
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	if direction.length() > 0:
		# Accelerate towards target velocity
		var target_velocity = direction * move_speed
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
	# Update attack timer
	if attack_timer > 0:
		attack_timer -= delta
		return

	# Find nearest enemy
	nearest_enemy = find_nearest_enemy()

	if nearest_enemy and global_position.distance_to(nearest_enemy.global_position) <= attack_range:
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
