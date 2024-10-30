@icon("res://components/drag_drop/3D/draggable_3d.svg")
class_name Draggable3D extends Node3D

signal drag_started
signal drag_ended

const GroupName: StringName = &"draggable"

## It only supports nodes that inherits from CollisionObject3D (Area3D, and PhysicsBody3D related)
@export var target: CollisionObject3D:
	set(value):
		if value != target:
			
			if is_inside_tree() and value == null and target is CollisionObject3D:
				if target.input_event.is_connected(on_target_input_event):
					target.input_event.disconnect(on_target_input_event)
					
				is_dragging = false
				
			target = value
			
			if target is CollisionObject3D and is_inside_tree():
				original_position = target.global_position
				
				if not target.input_event.is_connected(on_target_input_event):
					target.input_event.connect(on_target_input_event)

@export var reset_position_on_release: bool = false

var original_position: Vector3

var is_dragging: bool = false:
	set(value):
		if is_dragging != value:
			is_dragging = value
			
			if is_dragging:
				drag_started.emit()
			else:
				drag_ended.emit()
				
				if reset_position_on_release:
					target.global_position = original_position

	
func _enter_tree() -> void:
	add_to_group(GroupName)
	
	if target:
		target.input_event.connect(on_target_input_event)
		original_position = target.global_position


func get_rid() -> RID:
	return target.get_rid()
	
	
func on_target_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if InputHelper.is_mouse_visible():
		event = InputHelper.double_click_to_single(event)
		is_dragging = InputHelper.is_mouse_left_button_pressed(event)

	
