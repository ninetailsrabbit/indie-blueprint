## This node usually is placed in the center of the scenario we want to move around with panning
## and place the camera upwards relative to this node position
## SETUP: AerialCamera > CameraRotationX (Node3D) > CameraZoomPivot (Node3D, Set the position.y and apply vertical angle here) > Camera3D
@icon("res://components/camera/3D/aerial/aerial_camera.svg")
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
@export var camera_rotation_x: Node3D
@export var camera_zoom_pivot: Node3D

## For a true isometric projection use arctan(1/sqrt(2)) = 35.264.
## The 45-45 rule does not result in a true isometric projection. This configuration leads to a dimetric projection
@export_range(-180, 0, 0.01, "degrees") var vertical_rotation_angle: float = -35.264:
	set(value):
		vertical_rotation_angle = value
		camera_zoom_pivot.rotation_degrees.x = vertical_rotation_angle

@export var movement_mode: MovementMode = MovementMode.Free:
	set(value):
		if value != movement_mode:
			movement_mode = value
			set_process(not is_locked)
			changed_movement_mode.emit(movement_mode)

@export var rotate_button: MouseButton = MOUSE_BUTTON_RIGHT
@export var drag_button: MouseButton = MOUSE_BUTTON_LEFT
@export_category("Movement")
@export var movement_speed: float = 0.3
@export var smooth_movement: bool = true
@export var smooth_movement_lerp: float = 8.0
@export_category("Rotation")
@export_range(0.01, 1.0, 0.01) var mouse_sensitivity: float = 0.05
@export var rotation_speed: float = 0.1
@export var smooth_rotation: bool = true
@export var smooth_rotation_lerp: float = 6.0
@export_category("Drag")
@export var drag_speed: float = 0.03
@export_category("Edge panning")
## When enabled, the camera moves when the mouse reachs viewport boundaries
@export var edge_panning: bool = true
@export var edge_panning_mouse_modes: Array[Input.MouseMode] = [
	Input.MOUSE_MODE_CONFINED,
	Input.MOUSE_MODE_CONFINED_HIDDEN,
]
## An extra margin to detect the viewport boundaries
@export var edge_size: float = 5.0
@export var scroll_speed: float = 0.25
@export_category("Zoom")
@export var zoom_in_button: MouseButton = MOUSE_BUTTON_WHEEL_UP
@export var zoom_out_button: MouseButton = MOUSE_BUTTON_WHEEL_DOWN
@export var smooth_zoom: bool = true
@export var smooth_zoom_lerp: float = 6.0
@export_category("Perspective zoom")
@export var zoom_in_perspective_step: float = 2.0
@export var zoom_out_perspective_step: float = 2.0
@export var min_zoom_perspective: float = -5.0
@export var max_zoom_perspective: float = 5.0
## This curve controls how the camera rotation is modified when zooomin in-out, no curve means
## the camera rotation is not modified when zooming
@export var perspective_zoom_curve: Curve
@export_category("Ortographic zoom")
@export var zoom_in_ortographic_step: float = 2.5
@export var zoom_out_ortographic_step: float = 2.5
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
		set_process(not is_locked)

var motion_input: MotionInput = MotionInput.new()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if IndieBlueprintInputHelper.is_mouse_wheel_up_or_down(event):
				if dragging:
					return
				
				match camera.projection:
					Camera3D.ProjectionType.PROJECTION_ORTHOGONAL:
						target_zoom = camera.size + (zoom_in_ortographic_step * -1.0 if IndieBlueprintInputHelper.is_mouse_wheel_up(event) else zoom_out_ortographic_step * 1.0)
						target_zoom = clampf(target_zoom, min_zoom_size, max_zoom_size)
						
						if not smooth_zoom:
							camera.size = target_zoom
						
					Camera3D.ProjectionType.PROJECTION_PERSPECTIVE:
						target_zoom = camera.position.z + (zoom_in_perspective_step * -1.0 if IndieBlueprintInputHelper.is_mouse_wheel_up(event) else zoom_out_perspective_step * 1.0)
						target_zoom = clampf(target_zoom, min_zoom_perspective, max_zoom_perspective)
						
						if not smooth_zoom:
							camera.position.z = target_zoom
						
						
		dragging = movement_mode_is_drag() and event.pressed and event.button_index == drag_button
		rotating = event.pressed and event.button_index == rotate_button
	
	if event is InputEventMouseMotion:
		## pan camera
		if dragging:
			target_position += transform.basis.x * -event.relative.x * drag_speed \
				+ forward_vector * -event.relative.y * drag_speed / screen_ratio;
		
		if rotating:
			if smooth_rotation:
				target_rotation += -event.relative.x * mouse_sensitivity * rotation_speed
			else:
				rotate_y(-event.relative.x * mouse_sensitivity * rotation_speed)
				
			update_move_vectors()

## This values are used for the linear interpolation in the _process
var target_position: Vector3 
var target_rotation: float 
var target_zoom: float 


func _ready() -> void:
	if camera == null:
		camera = IndieBlueprintNodeTraversal.first_node_of_type(self, Camera3D.new())
	
	camera_zoom_pivot.rotation_degrees.x = vertical_rotation_angle
	
	screen_size = IndieBlueprintWindowManager.screen_size()
	screen_ratio = IndieBlueprintWindowManager.screen_ratio()
	
	update_move_vectors()
	set_process(not is_locked)
	set_process_input(not is_locked)
	
	target_position = position
	target_rotation = rotation.y
	target_zoom = camera.position.z


func _process(delta: float) -> void:
	motion_input.update()
	
	if edge_panning and Input.mouse_mode in edge_panning_mouse_modes:
		var mouse_position: Vector2 = get_viewport().get_mouse_position()
		var scroll_direction: Vector3 = Vector3.ZERO
		
		if mouse_position.x < edge_size:
			scroll_direction.x = -1
		elif mouse_position.x > screen_size.x - edge_size:
			scroll_direction.x = 1
			
		if mouse_position.y < edge_size:
			scroll_direction.z = -1
		elif mouse_position.y > screen_size.y - edge_size:
			scroll_direction.z = 1
			
		target_position += transform.basis * scroll_direction * scroll_speed
			
	if movement_mode_is_free():
		var input_direction: Vector2 = motion_input.input_direction
		var movement_direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
		
		target_position += movement_speed * movement_direction
		
	if smooth_movement:
		position = position.lerp(target_position, delta * smooth_movement_lerp)
	else:
		position = target_position
		
	if smooth_rotation:
		rotation.y = lerp(rotation.y, target_rotation, delta * smooth_rotation_lerp)
		
	if smooth_zoom:
			match camera.projection:
				Camera3D.ProjectionType.PROJECTION_ORTHOGONAL:
					camera.size = lerp(camera.size, target_zoom, delta * smooth_zoom_lerp)
				Camera3D.ProjectionType.PROJECTION_PERSPECTIVE:
					camera.position.z = lerp(camera.position.z, target_zoom, delta * smooth_zoom_lerp)
					
					if perspective_zoom_curve:
						camera.rotation_degrees.x = lerp(camera.rotation_degrees.x, perspective_zoom_curve.sample(camera.position.z), delta * smooth_zoom_lerp) 

## We want to have a vector that translates our camera, this is used when the movement is drag
func update_move_vectors() -> void:
	var offset: Vector3 = camera.global_position - global_position
	right_vector = camera.transform.basis.x
	forward_vector = Vector3(offset.x, 0, offset.z).normalized()


func apply_transform(aerial_camera_transform: AerialCameraTransform) -> void:
	target_position = to_local(aerial_camera_transform.last_transform.origin)
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
