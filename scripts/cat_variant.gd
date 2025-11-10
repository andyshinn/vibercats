extends Node3D
class_name CatVariant

## Allows swapping cat textures at runtime
## Attach this to the root Armature node of cat_native.tscn

@export_group("Cat Appearance")
@export var cat_texture: Texture2D:
	set(value):
		cat_texture = value
		_update_texture()

@export var eye_left_texture: Texture2D:
	set(value):
		eye_left_texture = value
		_update_texture()

@export var eye_right_texture: Texture2D:
	set(value):
		eye_right_texture = value
		_update_texture()

@export var tongue_texture: Texture2D:
	set(value):
		tongue_texture = value
		_update_texture()

@onready var skeleton: Skeleton3D = $CatSkeleton
@onready var cat_mesh: MeshInstance3D = $CatSkeleton/Cat
@onready var eye_l_mesh: MeshInstance3D = $CatSkeleton/eye_L
@onready var eye_r_mesh: MeshInstance3D = $CatSkeleton/eye_R
@onready var tongue_mesh: MeshInstance3D = $CatSkeleton/tongue2


func _ready() -> void:
	_update_texture()


func _update_texture() -> void:
	if not is_node_ready():
		return

	# Update main cat body texture
	if cat_texture and cat_mesh:
		var material = cat_mesh.get_active_material(0)
		if material:
			# Create a duplicate to avoid modifying the original
			material = material.duplicate()
			material.albedo_texture = cat_texture
			cat_mesh.set_surface_override_material(0, material)

	# Update left eye texture
	if eye_left_texture and eye_l_mesh:
		var material = eye_l_mesh.get_active_material(0)
		if material:
			material = material.duplicate()
			material.albedo_texture = eye_left_texture
			eye_l_mesh.set_surface_override_material(0, material)

	# Update right eye texture
	if eye_right_texture and eye_r_mesh:
		var material = eye_r_mesh.get_active_material(0)
		if material:
			material = material.duplicate()
			material.albedo_texture = eye_right_texture
			eye_r_mesh.set_surface_override_material(0, material)

	# Update tongue texture
	if tongue_texture and tongue_mesh:
		var material = tongue_mesh.get_active_material(0)
		if material:
			material = material.duplicate()
			material.albedo_texture = tongue_texture
			tongue_mesh.set_surface_override_material(0, material)


## Apply a complete cat variant (useful for programmatic setup)
func apply_variant(body: Texture2D, eye_l: Texture2D = null, eye_r: Texture2D = null, tongue: Texture2D = null) -> void:
	cat_texture = body
	if eye_l:
		eye_left_texture = eye_l
	if eye_r:
		eye_right_texture = eye_r
	if tongue:
		tongue_texture = tongue
