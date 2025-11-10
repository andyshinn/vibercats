extends Node

## Handles animation state transitions for the player cat using AnimationTree
## Switches between idle, walk, and run animations based on movement speed

@onready var cat_model: Node3D = $"../Cat"
@onready var animation_tree: AnimationTree = cat_model.get_node("AnimationTree")
@onready var player: CharacterBody3D = get_parent()

# BlendSpace parameter path
const BLEND_POSITION_PARAM = "parameters/BlendSpace/blend_position"

# Rotation speed for smooth turning
@export var rotation_speed: float = 10.0

# Speed thresholds for animation blending
@export var walk_threshold: float = 0.1  # Minimum speed to start walking

func _ready():
	if not animation_tree:
		push_error("AnimationTree not found! Make sure CatModel/AnimationTree exists.")
		return

	# Enable the animation tree
	animation_tree.active = true

	# Debug: Print AnimationTree info
	print("AnimationTree active: ", animation_tree.active)

func _process(delta: float):
	if not animation_tree or not cat_model:
		return

	# Get horizontal velocity (ignore Y component)
	var velocity_2d = Vector2(player.velocity.x, player.velocity.z)
	var speed = velocity_2d.length()

	# Map speed to BlendSpace1D position
	# BlendSpace points: idle=0.0, walk=1.0, run=2.0
	# Speed range: 0.0 to move_speed (5.0)
	# Walking ends at 30% of max speed (1.5), running starts there
	var blend_position = 0.0
	if speed < walk_threshold:
		blend_position = 0.0  # idle
	elif speed < player.move_speed * 0.3:  # Up to 30% of max speed (1.5)
		# Blend from idle (0.0) to walk (1.0)
		blend_position = remap(speed, walk_threshold, player.move_speed * 0.3, 0.0, 1.0)
	else:
		# Blend from walk (1.0) to run (2.0)
		blend_position = remap(speed, player.move_speed * 0.3, player.move_speed, 1.0, 2.0)
		blend_position = clamp(blend_position, 1.0, 2.0)

	# Set the blend position
	animation_tree.set(BLEND_POSITION_PARAM, blend_position)

	# Scale animation speed based on blend position and movement speed
	if speed > walk_threshold:
		var animation_speed = 1.0

		# Different speed scaling for walk vs run
		if blend_position < 1.0:
			# In idle->walk range: speed up the walk more
			# Blend position 0.0-1.0, animation speed 1.0-1.4
			animation_speed = lerp(1.4, 2.0, blend_position)
		else:
			# In walk->run range: normal to slightly faster
			# Blend position 1.0-2.0, animation speed 1.4-1.3
			var run_blend = blend_position - 1.0  # 0.0 to 1.0
			animation_speed = lerp(1.4, 1.3, run_blend)

		# Apply speed to the AnimationTree
		animation_tree.set("parameters/TimeScale/scale", animation_speed)
	else:
		# Reset to normal speed when idle
		animation_tree.set("parameters/TimeScale/scale", 1.0)

	# Debug: Print animation info every 60 frames (once per second at 60fps)
	if Engine.get_process_frames() % 60 == 0:
		print("Speed: %.2f | Blend Position: %.2f" % [speed, blend_position])

	# Rotate cat to face movement direction
	if speed > walk_threshold:
		# Calculate target rotation based on movement direction
		var movement_direction = Vector3(player.velocity.x, 0, player.velocity.z).normalized()
		var target_rotation = atan2(movement_direction.x, movement_direction.z)

		# Smoothly interpolate to target rotation
		var current_rotation = cat_model.rotation.y
		var new_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
		cat_model.rotation.y = new_rotation
