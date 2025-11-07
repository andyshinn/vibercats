extends CharacterBody3D

class_name Enemy

## Enemy AI for Viber Cats
## Uses Navigation for pathfinding around obstacles

@export var move_speed: float = 4.0
@export var max_health: float = 50.0
@export var damage: float = 10.0
@export var attack_range: float = 1.5
@export var attack_cooldown: float = 1.0

var current_health: float = 50.0
var attack_timer: float = 0.0
var target: Player = null

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

# Signals
signal died()

func _ready():
	current_health = max_health
	add_to_group("enemies")

	# Configure navigation agent
	if nav_agent:
		nav_agent.path_desired_distance = 0.5
		nav_agent.target_desired_distance = 1.5  # Match attack range so nav finishes when in attack position
		# Wait for first physics frame before using navigation
		call_deferred("_setup_navigation")

	# Find player
	call_deferred("_find_player")

func _setup_navigation():
	# NavigationServer needs to sync on physics frame before paths work
	pass

func _find_player():
	var players = get_tree().get_nodes_in_group("players")

	if players.size() > 1:
		push_warning("Multiple players detected! Expected 1, found ", players.size())

	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float):
	if attack_timer > 0:
		attack_timer -= delta

	if not target or not is_instance_valid(target):
		_find_player()
		return

	# Check if close enough to attack
	var distance_to_player = global_position.distance_to(target.global_position)

	# Apply gravity every frame
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if distance_to_player <= attack_range:
		# Attack player
		if attack_timer <= 0:
			attack_player()
			attack_timer = attack_cooldown
	else:
		# Move towards player using navigation
		if nav_agent:
			nav_agent.target_position = target.global_position
		move_towards_target(delta)

	move_and_slide()

func move_towards_target(delta: float):
	if not nav_agent:
		return

	# Check if path is valid
	if nav_agent.is_navigation_finished():
		return

	# Check if we have a valid path
	if not nav_agent.is_target_reachable():
		return

	var next_path_position = nav_agent.get_next_path_position()

	# Calculate direction
	var direction = global_position.direction_to(next_path_position)

	# If direction is zero, navigation hasn't updated yet
	if direction.length_squared() < 0.01:
		return

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

func attack_player():
	if not target or not is_instance_valid(target):
		return

	if target.has_method("take_damage"):
		target.take_damage(damage)

func take_damage(amount: float):
	current_health -= amount

	if current_health <= 0:
		die()

func die():
	died.emit()
	spawn_cat_food()
	queue_free()

func spawn_cat_food():
	# Load cat food scene
	var cat_food_scene = preload("res://scenes/cat_food.tscn")
	if cat_food_scene:
		var cat_food = cat_food_scene.instantiate()
		get_parent().add_child(cat_food)
		cat_food.global_position = global_position
