extends Area3D

class_name CatFood

## Cat food collectible that acts as XP
## Moves towards player when in magnet range

@export var xp_value: int = 1
@export var magnet_range: float = 5.0
@export var move_speed: float = 10.0

var player: Player = null
var being_collected: bool = false

func _ready():
	add_to_group("cat_food")
	body_entered.connect(_on_body_entered)

	# Find player
	call_deferred("_find_player")

func _find_player():
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float):
	if not player or not is_instance_valid(player):
		_find_player()
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	# Check if in magnet range
	if distance_to_player <= magnet_range:
		being_collected = true

	# Move towards player if being collected
	if being_collected:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * move_speed * delta

func _on_body_entered(body: Node3D):
	if body is Player:
		collect(body)

func collect(_p: Player):
	# Notify player stats system
	var player_stats = get_node_or_null("/root/PlayerStats")
	if player_stats and player_stats.has_method("add_xp"):
		player_stats.add_xp(xp_value)

	queue_free()
