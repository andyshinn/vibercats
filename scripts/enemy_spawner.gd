extends Node3D

class_name EnemySpawner

## Spawns enemies off-screen around the player
## Spawn rate increases over time

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_distance: float = 10.0
@export var max_enemies: int = 100

# Difficulty scaling
@export var spawn_rate_increase: float = 0.95  # Multiplier per wave (spawn faster over time)
@export var min_spawn_interval: float = 0.5

var spawn_timer: float = 0.0
var player: Player = null
var enemy_count: int = 0

func _ready():
	call_deferred("_find_player")

func _find_player():
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]

func _process(delta: float):
	if not player or not is_instance_valid(player):
		_find_player()
		return

	spawn_timer -= delta

	if spawn_timer <= 0 and enemy_count < max_enemies:
		spawn_enemy()
		spawn_timer = spawn_interval

		# Gradually increase spawn rate
		spawn_interval = max(min_spawn_interval, spawn_interval * spawn_rate_increase)

func spawn_enemy():
	if not enemy_scene:
		push_error("Enemy scene not set!")
		return

	if not player:
		return

	# Get random position around player, off-screen
	var spawn_pos = get_random_spawn_position()

	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_pos

	# Connect to enemy death signal to track count
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)

	enemy_count += 1

func get_random_spawn_position() -> Vector3:
	if not player:
		return Vector3.ZERO

	# Get random angle
	var angle = randf() * TAU

	# Calculate position at spawn_distance from player
	var offset = Vector3(
		cos(angle) * spawn_distance,
		0.6,  # Spawn slightly above nav mesh surface
		sin(angle) * spawn_distance
	)

	return player.global_position + offset

func _on_enemy_died():
	enemy_count -= 1
