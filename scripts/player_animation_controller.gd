extends Node

## Handles animation state transitions for the player cat using AnimationTree
## Switches between walk and idle animations based on movement with smooth blending

@onready var animation_tree: AnimationTree = $"../Cat/AnimationTree"
@onready var player: CharacterBody3D = get_parent()
@onready var cat_model: Node3D = $"../Cat"

# State machine parameter for transitions
const MOVEMENT_BLEND_PARAM = "parameters/movement/blend_amount"

# Rotation speed for smooth turning
@export var rotation_speed: float = 10.0

# Animation blending speed
@export var blend_speed: float = 5.0

func _ready():
	if not animation_tree:
		push_error("AnimationTree not found! Make sure CatModel/AnimationTree exists.")
		return

	# Enable the animation tree
	animation_tree.active = true

	# Set the walk animation speed
	var timescale_path = "parameters/walk_speed/scale"
	animation_tree.set(timescale_path, 4.0)

	# Debug: Print AnimationTree info
	print("AnimationTree active: ", animation_tree.active)
	print("Set TimeScale to: ", animation_tree.get(timescale_path))

func _process(delta: float):
	if not animation_tree:
		return

	# Get horizontal velocity (ignore Y component)
	var velocity_2d = Vector2(player.velocity.x, player.velocity.z)
	var is_moving = velocity_2d.length() > 0.1

	# Blend between idle (0.0) and walk (1.0) with smooth transitions
	var blend_target = 1.0 if is_moving else 0.0
	var current_blend = animation_tree.get(MOVEMENT_BLEND_PARAM)
	var new_blend = lerp(current_blend, blend_target, blend_speed * delta)
	animation_tree.set(MOVEMENT_BLEND_PARAM, new_blend)

	# Debug: Print animation info every 60 frames (once per second at 60fps)
	if Engine.get_process_frames() % 60 == 0:
		print("Blend amount: ", new_blend, " | Moving: ", is_moving)
		# Try to read the TimeScale value
		var timescale_path = "parameters/walk_speed/scale"
		var timescale_value = animation_tree.get(timescale_path)
		if timescale_value != null:
			print("TimeScale: ", timescale_value)

	# Optionally adjust animation speed based on movement speed
	# Uncomment to make animation speed match player velocity
	# var speed_multiplier = velocity_2d.length() / player.move_speed
	# animation_tree.set("parameters/TimeScale/scale", clamp(speed_multiplier, 0.5, 2.0))

	# Rotate cat to face movement direction
	if is_moving and cat_model:
		# Calculate target rotation based on movement direction
		var movement_direction = Vector3(player.velocity.x, 0, player.velocity.z).normalized()
		var target_rotation = atan2(movement_direction.x, movement_direction.z)

		# Smoothly interpolate to target rotation
		var current_rotation = cat_model.rotation.y
		var new_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
		cat_model.rotation.y = new_rotation
