class_name ScanInteractable extends Node3D

signal scan_started(object: Node3D)
signal scan_ended(object: Node3D)

@onready var mouse_rotator_component_3d: MouseRotatorComponent3D = $MouseRotatorComponent3D
@onready var camera_3d: Camera3D = $Camera3D
@onready var marker_3d: Marker3D = $Camera3D/Marker3D


var current_object: Node3D:
	set(new_object):
		if new_object != current_object:
			current_object = new_object
			mouse_rotator_component_3d.target = current_object
				
			set_process_unhandled_input(current_object != null)


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		end_scan()


func _ready() -> void:
	set_process_unhandled_input(current_object != null)
	
	
func blur_camera() -> void:
	var origin_camera: Camera3D = get_window().get_camera_3d()
	origin_camera.attributes.dof_blur_far_enabled = true
	origin_camera.attributes.dof_blur_near_enabled = true
	origin_camera.attributes.dof_blur_far_distance = 2.0


func recover_camera() -> void:
	var origin_camera: Camera3D = get_window().get_camera_3d()
	origin_camera.attributes.dof_blur_far_enabled = false
	origin_camera.attributes.dof_blur_near_enabled = false
	

func scan(node: Node3D) -> void:
	if current_object:
		return
	
	scan_started.emit(current_object)
	blur_camera()
	
	current_object = node.duplicate()
	marker_3d.add_child(current_object)
	current_object.position = Vector3.ZERO
	
	for interactable: Interactable3D in InteractionKit3DPluginUtilities.find_nodes_of_custom_class(current_object, Interactable3D):
		## Deactivate the interactables that can be scanned to not interrupt the other ones
		if interactable.scannable:
			interactable.deactivate()
	

func end_scan() -> void:
	recover_camera()
	
	if current_object:
		scan_ended.emit(current_object)
	
	for child: Node in marker_3d.get_children():
		child.free()
	
	current_object = null
