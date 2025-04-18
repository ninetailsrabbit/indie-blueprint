## This node usually is placed in the center of the scenario we want to move around with panning
## and place the camera upwards relative to this node position that is used as pivot
class_name AerialCamera extends Node3D

signal changed_movement_mode(new_mode: MovementMode)
signal movement_free_started(last_transform: AerialCameraTransform)

class AerialCameraTransform:
	var last_transform: Transform3D
	var camera_size: float
	var camera_fov: float
	
	func _init(_transform: Transform3D, _camera_size: float, _camera_fov: float) -> void:
		last_transform = _transform
		camera_size = _camera_size
		camera_fov = _camera_fov


@export var camera: Camera3D
## For a true isometric projection use arctan(1/sqrt(2)) = 35.264.
## The 45-45 rule does not result in a true isometric projection. This configuration leads to a dimetric projection
@export_range(-180, 0, 0.01, "degrees") var vertical_rotation_angle: float = -35.264:
	set(value):
		vertical_rotation_angle = value
		camera.rotation_degrees.x = vertical_rotation_angle
		
@export var movement_mode: MovementMode = MovementMode.Free:
	set(value):
		if value != movement_mode:
			movement_mode = value
			set_process(movement_mode_is_free())
			changed_movement_mode.emit(movement_mode)

@export var rotate_button: MouseButton = MOUSE_BUTTON_RIGHT
@export var drag_button: MouseButton = MOUSE_BUTTON_LEFT
@export_category("Movement")
@export var movement_speed: float = 10.0
@export_category("Drag")
@export var move_drag_speed: float = 0.03
@export var rotate_drag_speed: float = 0.01
@export_category("Zoom")
@export var zoom_in_button: MouseButton = MOUSE_BUTTON_WHEEL_UP
@export var zoom_out_button: MouseButton = MOUSE_BUTTON_WHEEL_DOWN
@export_category("Perspective zoom")
@export var fov_in_step: float = 2.0
@export var fov_out_step: float = 2.0
@export var min_fov_size: float = 45.0
@export var max_fov_size: float = 80.0
@export var angle_correction_below_fov: float = 60.0
@export_category("Ortographic zoom")
@export var zoom_in_step: float = 0.5
@export var zoom_out_step: float = 0.5
@export var min_zoom_size: float = 10.0
@export var max_zoom_size: float = 30.0

enum MovementMode {
	Free,
	Drag
}

var screen_size: Vector2
var screen_ratio: float
var dragging: bool = false
var rotating: bool = false

var right_vector: Vector3
var forward_vector: Vector3

var is_locked: bool = false:
	set(value):
		is_locked = value
		set_process_input(not is_locked)

var motion_input: MotionInput = MotionInput.new()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if IndieBlueprintInputHelper.is_mouse_wheel_up_or_down(event):
				if dragging:
					return
				
				match camera.projection:
					Camera3D.ProjectionType.PROJECTION_ORTHOGONAL:
						var new_zoom_size: float = camera.size + (zoom_in_step * -1.0 if IndieBlueprintInputHelper.is_mouse_wheel_up(event) else zoom_out_step * 1.0)
						camera.size = clampf(new_zoom_size, min_zoom_size, max_zoom_size)
						
					Camera3D.ProjectionType.PROJECTION_PERSPECTIVE:
						var new_zoom_size: float = camera.fov + (fov_in_step * -1.0 if IndieBlueprintInputHelper.is_mouse_wheel_up(event) else fov_out_step * 1.0)
						camera.fov = clampf(new_zoom_size, min_fov_size, max_fov_size)
						
						if camera.fov < angle_correction_below_fov:
							pass
						
						
		dragging = movement_mode_is_drag() and event.pressed and event.button_index == drag_button
		rotating = event.pressed and event.button_index == rotate_button
	
	if event is InputEventMouseMotion:
		## pan camera
		if dragging:
			global_position += camera.global_transform.basis.x * -event.relative.x * move_drag_speed \
				+ forward_vector * -event.relative.y * move_drag_speed / screen_ratio;
		
		if rotating:
			rotate_y(-event.relative.x * 0.5 * rotate_drag_speed)
			update_move_vectors()
	

func _ready() -> void:
	if camera == null:
		camera = IndieBlueprintNodeTraversal.first_node_of_type(self, Camera3D.new())
	
	camera.rotation_degrees.x = vertical_rotation_angle
	
	screen_size = IndieBlueprintWindowManager.screen_size()
	screen_ratio = IndieBlueprintWindowManager.screen_ratio()
	
	update_move_vectors()
	set_process(movement_mode_is_free())
	set_process_input(not is_locked)


func _process(delta: float) -> void:
	motion_input.update()
	handle_movement(delta)


func handle_movement(delta: float = get_process_delta_time()) -> void:
	if movement_mode_is_free():
		var input_direction: Vector2 = motion_input.input_direction
		if motion_input.previous_input_direction.is_zero_approx() and not input_direction.is_zero_approx():
			movement_free_started.emit(AerialCameraTransform.new(global_transform, camera.size, camera.fov))
		
		if not input_direction.is_zero_approx():
			var velocity: Vector3 = Vector3.ZERO
			
			match input_direction:
				Vector2.UP:
					velocity -= camera.global_transform.basis.z
				Vector2.DOWN:
					velocity += camera.global_transform.basis.z
				Vector2.RIGHT:
					velocity += camera.global_transform.basis.x
				Vector2.LEFT:
					velocity -= camera.global_transform.basis.x
				
			if IndieBlueprintVectorHelper.is_diagonal_direction_v2(input_direction):
				## Diagonal RIGHT - UP
				if sign(input_direction.x) == 1 and sign(input_direction.y) == -1:
					velocity += camera.global_transform.basis.x - camera.global_transform.basis.z
				
				## Diagonal LEFT - UP
				elif sign(input_direction.x) == -1 and sign(input_direction.y) == -1:
					velocity -= camera.global_transform.basis.x + camera.global_transform.basis.z
					
				## DIAGONAL RIGHT - DOWN
				elif sign(input_direction.x) == 1 and sign(input_direction.y) == 1:
					velocity += camera.global_transform.basis.x + camera.global_transform.basis.z
					
				## DIAGONAL LEFT-DOWN
				elif sign(input_direction.x) == -1 and sign(input_direction.y) == 1:
					velocity -= camera.global_transform.basis.x - camera.global_transform.basis.z
					
			velocity.y = 0
			global_translate(velocity.normalized() * delta * movement_speed)
	
	
## We want to have a vector that translates our camera, this is used when the movement is drag
func update_move_vectors() -> void:
	var offset: Vector3 = camera.global_position - global_position
	right_vector = camera.transform.basis.x
	forward_vector = Vector3(offset.x, 0, offset.z).normalized()


func apply_transform(aerial_camera_transform: AerialCameraTransform) -> void:
	global_transform = aerial_camera_transform.last_transform
	camera.size = aerial_camera_transform.camera_size
	camera.fov = aerial_camera_transform.camera_fov
	

func lock() -> void:
	is_locked = true
	
	
func unlock() -> void:
	is_locked = false
	
	
func movement_mode_is_free() -> bool:
	return movement_mode == MovementMode.Free


func movement_mode_is_drag() -> bool:
	return movement_mode == MovementMode.Drag
