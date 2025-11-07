extends Camera3D

## Camera controller for isometric view
## Follows the player and keeps them centered

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 20, 15)
@export var smoothing: float = 5.0

func _ready():
	if not target:
		var players = get_tree().get_nodes_in_group("players")
		if players.size() > 0:
			target = players[0]

func _process(delta: float):
	if target and is_instance_valid(target):
		var target_position = target.global_position + offset
		global_position = global_position.lerp(target_position, smoothing * delta)

		# Always look at the player
		look_at(target.global_position, Vector3.UP)
