class_name FixedCamera3D extends Node3D

@export var camera_pivot: Node3D
@export var camera: Camera3D
@export var rotation_speed: float = 5.0
@export var raycast_distance: float = 100.0
@export_range(0, 360.0, 0.5, "degrees") var camera_vertical_limit: float = 89.0
## 0 Means the rotation on the X-axis is not limited
@export_range(0, 360.0, 0.5, "degrees") var camera_horizontal_limit: float = 0.0
@export var use_quaternions: bool = true


@onready var current_vertical_limit: float:
	set(value):
		current_vertical_limit = clampf(value, 0.0, rad_to_deg(TAU))
		
@onready var current_horizontal_limit: float:
	set(value):
		current_horizontal_limit = clampf(value, 0.0, rad_to_deg(TAU))

var raycast_result: RaycastResult
var locked: bool = false


func _ready() -> void:
	current_horizontal_limit = camera_horizontal_limit
	current_vertical_limit = camera_vertical_limit
	

func _physics_process(delta: float) -> void:
	raycast_result = IndieBlueprintCamera3DHelper.project_raycast_to_mouse(camera, raycast_distance)
	var target_position: Vector3 = raycast_result.projection() if raycast_result.normal.is_zero_approx() else raycast_result.position
	var desired_transform = global_transform.looking_at(target_position, Vector3.UP)
	
	if use_quaternions:
		var current_quat: Quaternion = global_transform.basis.get_rotation_quaternion()
		var desired_quat: Quaternion = desired_transform.basis.get_rotation_quaternion()
		
		var interpolated_quat: Quaternion = current_quat.slerp(desired_quat, delta * rotation_speed)
		# Apply the interpolated quaternion to the pivot's basis (rotation)
		# Make sure to orthonormalize to prevent skewing over time
		global_transform.basis = Basis(interpolated_quat).orthonormalized()

	else:
		global_transform = global_transform.interpolate_with(desired_transform, delta * rotation_speed)
	
	camera_pivot.rotation_degrees.y = limit_horizontal_rotation(camera_pivot.rotation_degrees.y)
	camera_pivot.rotation_degrees.x = limit_vertical_rotation(camera_pivot.rotation_degrees.x)


func lock() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	locked = true


func unlock() -> void:
	set_physics_process(true)
	set_process_unhandled_input(true)
	locked = false


func limit_vertical_rotation(angle: float) -> float:
	if current_vertical_limit > 0:
		return clampf(angle, -current_vertical_limit, current_vertical_limit)
	
	return angle


func limit_horizontal_rotation(angle: float) -> float:
	if current_horizontal_limit > 0:
		return clampf(angle, -current_horizontal_limit, current_horizontal_limit)
	
	return angle
