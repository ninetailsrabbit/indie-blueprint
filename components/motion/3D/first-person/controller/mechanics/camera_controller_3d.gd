@icon("res://components/motion/3D/first-person/controller/mechanics/camera_controller_3d.svg")
class_name CameraController3D extends Node3D

@export var actor: FirstPersonController
@export var camera: Camera3D
## 0 Means the rotation on the Y-axis is not limited
@export_range(0, 360, 1, "degrees") var camera_vertical_limit = 89
## 0 Means the rotation on the X-axis is not limited
@export_range(0, 360, 1, "degrees") var camera_horizontal_limit = 0
@export_group("Swing head")
@export var swing_head_enabled: bool = true:
	set(value):
		swing_head_enabled = value
		if not swing_head_enabled and not bob_enabled:
			set_physics_process(false)
			
@export_range(0, 360.0, 0.01) var swing_rotation_degrees = 1.5
@export var swing_lerp_factor = 5.0
@export var swing_lerp_recovery_factor = 7.5
@export_group("Bob head")
@export var bob_enabled: bool = true:
	set(value):
		bob_enabled = value
		if not swing_head_enabled and not bob_enabled:
			set_physics_process(false)
@export var bob_head: Node3D
@export var bob_speed: float = 10.0
@export var bob_intensity: float = 0.03
@export var bob_lerp_speed = 5.0

@onready var current_vertical_limit: int:
	set(value):
		current_vertical_limit = clamp(value, 0, 360)
		
@onready var current_horizontal_limit: int:
	set(value):
		current_horizontal_limit = clamp(value, 0, 360)
		

var last_mouse_input: Vector2
var mouse_sensitivity: float = 3.0
var locked: bool = false

var original_camera_rotation: Vector3
var original_head_bob_position: Vector3 = Vector3.ZERO

var bob_index: float = 0.0
var bob_vector: Vector3 = Vector3.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and InputHelper.is_mouse_captured():
		var motion: InputEventMouseMotion = event.xformed_by(get_tree().root.get_final_transform())
		last_mouse_input = motion.relative
		
		rotate_camera(motion)
		
		
func _ready() -> void:
	assert(actor is FirstPersonController, "CameraController: This node needs a FirstPersonController node referenced to apply the camera movement")
	
	current_horizontal_limit = camera_horizontal_limit
	current_vertical_limit = camera_vertical_limit
	original_camera_rotation = camera.rotation
	original_head_bob_position = bob_head.position
	
	mouse_sensitivity = SettingsManager.get_accessibility_section("mouse_sensitivity")
	
	SettingsManager.updated_setting_section.connect(on_mouse_sensitivity_changed)
	

func _physics_process(delta: float) -> void:
	swing_head(delta)
	headbob(delta)


func rotate_camera(motion: InputEventMouseMotion) -> void:
	var mouse_sens = mouse_sensitivity / 1000 # radians/pixel, 3 becomes 0.003
		
	var twistInput = motion.relative.x * mouse_sens ## Giro
	var pitchInput = motion.relative.y * mouse_sens ## Cabeceo
	
	var mouse_rotation: Vector3 = Vector3(-pitchInput, -twistInput, 0)
	
	actor.rotate_y(mouse_rotation.y)
	rotate_x(mouse_rotation.x)
	
	actor.rotation_degrees.y = limit_horizontal_rotation(actor.rotation_degrees.y)
	rotation_degrees.x = limit_vertical_rotation(rotation_degrees.x)
	
	orthonormalize()


func limit_vertical_rotation(angle: float) -> float:
	if current_vertical_limit > 0:
		return clamp(angle, -current_vertical_limit, current_vertical_limit)
	
	return angle


func limit_horizontal_rotation(angle: float) -> float:
	if current_horizontal_limit > 0:
		return clamp(angle, -current_horizontal_limit, current_horizontal_limit)
	
	return angle


func lock() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	locked = true


func unlock() -> void:
	set_physics_process(true)
	set_process_unhandled_input(true)
	locked = false
	
	

func swing_head(delta: float) -> void:
	if swing_head_enabled and actor.is_grounded:
		var direction = actor.motion_input.input_direction
		
		if direction in VectorHelper.horizontal_directions_v2:
			camera.rotation.z = lerp_angle(camera.rotation.z, -sign(direction.x) * deg_to_rad(swing_rotation_degrees), swing_lerp_factor * delta)
		else:
			camera.rotation.z = lerp_angle(camera.rotation.z, original_camera_rotation.z, swing_lerp_recovery_factor * delta)


func headbob(delta: float) -> void:
	if bob_enabled and actor.is_grounded:
	
		bob_index += bob_speed * delta
		
		if actor.is_grounded and not actor.motion_input.input_direction.is_zero_approx():
			bob_vector = Vector3(sin(bob_index / 2.0), sin(bob_index), bob_vector.z)
			
			bob_head.position = Vector3(
				lerp(bob_head.position.x, bob_vector.x * bob_intensity, delta * bob_lerp_speed),
				lerp(bob_head.position.y, bob_vector.y * (bob_intensity * 2), delta * bob_lerp_speed),
				bob_head.position.z
			)
			
		else:
			bob_head.position = Vector3(
				lerp(bob_head.position.x, original_head_bob_position.x, delta * bob_lerp_speed),
				lerp(bob_head.position.y, original_head_bob_position.y, delta * bob_lerp_speed),
				bob_head.position.z
			)

#region Camera rotation
func change_horizontal_rotation_limit(new_rotation: int) -> void:
	current_horizontal_limit = new_rotation
	
func change_vertical_rotation_limit(new_rotation: int) -> void:
	current_vertical_limit = new_rotation
	
func return_to_original_horizontal_rotation_limit() -> void:
	current_horizontal_limit = camera_horizontal_limit
	
func return_to_original_vertical_rotation_limit() -> void:
	current_vertical_limit = camera_vertical_limit
#endregion

func on_mouse_sensitivity_changed(section: String, key: String, value: Variant) -> void:
	if section == GameSettings.AccessibilitySection and key == GameSettings.MouseSensivitySetting:
		mouse_sensitivity = value
