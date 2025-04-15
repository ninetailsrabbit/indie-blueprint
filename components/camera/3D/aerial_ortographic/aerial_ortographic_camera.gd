## This node usually is placed in the center of the scenario we want to move around with panning
## and place the camera upwards relative to this node position
class_name AerialOrtographicCamera extends Node3D

@export var camera: Camera3D
@export var move_drag_speed: float = 0.05
@export var rotate_drag_speed: float = 0.01
@export var zoom_in_step: float = 0.5
@export var zoom_out_step: float = 0.5
@export var min_zoom_size: float = 10.0
@export var max_zoom_size: float = 30.0

var screen_ratio: float
var dragging: bool
var dragging_left: bool

var right_vector: Vector3
var forward_vector: Vector3

var is_locked: bool = true:
	set(value):
		is_locked = value
		set_process_input(not is_locked)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if IndieBlueprintInputHelper.is_mouse_wheel_up_or_down(event):
				if dragging:
					return
					
				var new_zoom_size: float = camera.size + (zoom_in_step * -1.0 if IndieBlueprintInputHelper.is_mouse_wheel_up(event) else zoom_out_step * 1.0)
				camera.size = clampf(new_zoom_size, min_zoom_size, max_zoom_size)
		else:
			if event.pressed:
				dragging = true;
				dragging_left = event.button_index == MOUSE_BUTTON_LEFT
			else:
				dragging = false
		
	elif event is InputEventMouseMotion and dragging:
		## pan camera
		if dragging_left:
			global_position += camera.global_transform.basis.x * -event.relative.x * move_drag_speed \
				+ forward_vector * -event.relative.y * move_drag_speed / screen_ratio;
		else:
			rotate_y(-event.relative.x * 0.5 * rotate_drag_speed)
			update_move_vectors()


func _ready() -> void:
	if camera == null:
		camera = IndieBlueprintNodeTraversal.first_node_of_type(self, Camera3D.new())
	
	screen_ratio = IndieBlueprintWindowManager.screen_ratio()
	
	update_move_vectors()
	set_process_input(not is_locked)
	

## We want to have a vector that translates our camera
func update_move_vectors() -> void:
	var offset: Vector3 = camera.global_position - global_position
	right_vector = camera.transform.basis.x
	forward_vector = Vector3(offset.x, 0, offset.z).normalized()


func lock() -> void:
	is_locked = true
	
	
func unlock() -> void:
	is_locked = false
