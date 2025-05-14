class_name IndieBlueprintDraggable2D extends Button

signal dragged
signal released
signal locked
signal unlocked

@export var draggable: Node
@export var drag_smooth_lerp_factor: float = 20.0
@export var screen_limit: bool = true


var is_locked: bool = false:
	set(value):
		if value != is_locked:
			is_locked = value
			
			if is_locked:
				locked.emit()
			else:
				unlocked.emit()
			
			set_process(is_dragging and not is_locked)
			
var is_dragging: bool = false:
	set(value):
		if value != is_dragging:
			is_dragging = value
			
			if is_dragging:
				dragged.emit()
			else:
				released.emit()
		
			set_process(is_dragging and not is_locked)


var original_z_index: int = 0
var original_position: Vector2 = Vector2.ZERO
var original_rotation: float = 0.0
var current_position: Vector2 = Vector2.ZERO
var m_offset: Vector2 = Vector2.ZERO

var last_mouse_position: Vector2
var velocity: Vector2


func _process(delta: float) -> void:
	if not is_locked and is_dragging:
		last_mouse_position = draggable.global_position
		
		if drag_smooth_lerp_factor > 0:
			draggable.global_position = draggable.global_position.lerp(get_global_mouse_position(), drag_smooth_lerp_factor * delta)
		else:
			draggable.global_position = get_global_mouse_position()
			
		current_position = draggable.global_position + m_offset
		
		if screen_limit:
			draggable.global_position = Vector2(
				clampf(draggable.global_position.x, 0 , get_viewport_rect().size.x), 
				clampf(draggable.global_position.y, 0 , get_viewport_rect().size.y)
			)
		

func _ready() -> void:
	if draggable == null:
		draggable = get_parent()
		
	assert(is_instance_valid(draggable) and (draggable is Node2D or draggable is Control), "IndieBlueprintDraggable2D: This mouse drag region needs a valid Node2D or Control to works properly")
	
	set_process(false)
	
	#position = Vector2.ZERO
	self_modulate.a8 = 0
	
	original_position = draggable.global_position
	original_rotation = draggable.rotation
	original_z_index = draggable.z_index
	
	button_down.connect(on_mouse_drag_region_dragged)
	button_up.connect(on_mouse_drag_region_released)
	anchors_preset = Control.PRESET_FULL_RECT

	
func lock() -> void:
	is_locked = true


func unlock() -> void:
	is_locked = false

#endregion

#region Signal callbacks
func on_mouse_drag_region_dragged() -> void:
	if not is_locked:
		is_dragging = true
		draggable.z_index = original_z_index + 100
		draggable.z_as_relative = false
		m_offset = draggable.global_position - get_global_mouse_position()


func on_mouse_drag_region_released() -> void:
	if not is_locked:
		is_dragging = false
		draggable.z_index = original_z_index
		draggable.z_as_relative = true
#endregion
