@icon("res://components/drag_drop/3D/drag_drop_3d.svg")
class_name DragAndDrop3D extends Node3D


@export var origin_camera: Camera3D
@export var drag_distance_from_camera: float = 20.0

var current_draggable: Draggable3D:
	set(value):
		if value != current_draggable:
			current_draggable = value
			
			set_process_unhandled_input(current_draggable is Draggable3D)


func _unhandled_input(event: InputEvent) -> void:
	if InputHelper.is_mouse_visible() and event is InputEventMouseMotion and current_draggable:
		handle_drag_motion()


func _ready() -> void:
	await get_tree().current_scene.ready
	
	for draggable: Draggable3D in get_tree().get_nodes_in_group(Draggable3D.GroupName):
		draggable.drag_started.connect(on_draggable_drag_started.bind(draggable))
		draggable.drag_ended.connect(on_draggable_drag_ended.bind(draggable))
	
	get_tree().root.child_entered_tree.connect(on_child_entered_tree)
	get_tree().root.child_exiting_tree.connect(on_child_exiting_tree)
	

func handle_drag_motion():
	if origin_camera and current_draggable:
		var mouse_position: Vector2 = get_viewport().get_mouse_position()
		
		var world_space := get_world_3d().direct_space_state
		var from := origin_camera.project_ray_origin(mouse_position)
		var to := origin_camera.project_position(mouse_position, drag_distance_from_camera)
		
		var ray_query = PhysicsRayQueryParameters3D.create(
			from, 
			to,
		)
		
		ray_query.exclude = [current_draggable.get_rid()]
		
		ray_query.collide_with_areas = false
		ray_query.collide_with_bodies = true
		
		var result := world_space.intersect_ray(ray_query)
	
		if result.has("position"):
			current_draggable.target.global_position = result.position
	

#region Signal callbacks
func on_draggable_drag_started(draggable: Draggable3D) -> void:
	current_draggable = draggable


func on_draggable_drag_ended(_draggable: Draggable3D) -> void:
	current_draggable = null
	

func on_child_entered_tree(child: Node) -> void:
	if child is Draggable3D:
		child.drag_started.connect(on_draggable_drag_started.bind(child))
		child.drag_ended.connect(on_draggable_drag_ended.bind(child))
	
	
func on_child_exiting_tree(child: Node) -> void:
	if child is Draggable3D:
		if child.drag_started.is_connected(on_draggable_drag_started):
			child.drag_started.disconnect(on_draggable_drag_started)
			
		if child.drag_ended.is_connected(on_draggable_drag_started):
			child.drag_ended.disconnect(on_draggable_drag_ended)
	
#endregion
