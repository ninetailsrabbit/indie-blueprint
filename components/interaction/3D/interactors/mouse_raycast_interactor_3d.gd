@icon("res://components/interaction/3D/interactors/interactor.svg")
class_name MouseRayCastInteractor3D extends Node3D

@export var origin_camera: Camera3D
@export var ray_length: float = 100.0
@export var interact_mouse_button = MOUSE_BUTTON_LEFT
@export var cancel_interact_input_action: StringName = InputControls.CancelInteraction

@onready var current_camera: Camera3D = origin_camera:
	set(new_camera):
		if new_camera != current_camera:
			current_camera = new_camera
			
			set_process_unhandled_input(current_camera is Camera3D)
			set_process(current_camera is Camera3D)

var current_interactable: IndieBlueprintInteractable3D
var focused: bool = false
var interacting: bool = false
var mouse_position: Vector2 = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if is_processing() and current_camera is Camera3D and event is InputEventMouseButton:
		mouse_position = (event as InputEventMouseButton).position
		
		if interact_mouse_button == MOUSE_BUTTON_LEFT and IndieBlueprintInputHelper.is_mouse_left_click(event) \
			or interact_mouse_button == MOUSE_BUTTON_RIGHT and IndieBlueprintInputHelper.is_mouse_right_click(event):
				interact(current_interactable)
	
	if is_processing() and InputMap.has_action(cancel_interact_input_action) and Input.is_action_just_pressed(cancel_interact_input_action) and current_interactable is IndieBlueprintInteractable3D:
		cancel_interact(current_interactable)


func _ready() -> void:
	set_process_unhandled_input(current_camera is Camera3D)
	set_process(current_camera is Camera3D)
	

func _process(_delta: float) -> void:
	var detected_interactable = get_detected_interactable()
	
	if detected_interactable:
		if current_interactable == null and not focused:
			focus(detected_interactable)
	else:
		if focused and not interacting and current_interactable:
			unfocus(current_interactable)


func get_detected_interactable():
	var world_space := get_world_3d().direct_space_state
	var from := origin_camera.project_ray_origin(mouse_position)
	var to := from + origin_camera.project_ray_normal(mouse_position) * ray_length
	
	var ray_query = PhysicsRayQueryParameters3D.create(
		from, 
		to,
		IndieBlueprintGameGlobals.world_collision_layer | IndieBlueprintGameGlobals.interactables_collision_layer | IndieBlueprintGameGlobals.grabbables_collision_layer
	)
	
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = true
	
	var result := world_space.intersect_ray(ray_query)
	
	if IndieBlueprintInputHelper.is_mouse_visible() and result.has("collider") and result["collider"] is IndieBlueprintInteractable3D:
		return result.collider as IndieBlueprintInteractable3D
		
	return null


func interact(interactable: IndieBlueprintInteractable3D):
	if interactable:
		interacting = true
		
		interactable.interacted.emit()
		IndieBlueprintGlobalGameEvents.interactable_3d_interacted.emit(interactable)
	

func cancel_interact(interactable: IndieBlueprintInteractable3D = current_interactable):
	if interactable:
		interacting = false
		focused = false
		
		
		interactable.canceled_interaction.emit()
		IndieBlueprintGlobalGameEvents.interactable_3d_canceled_interaction.emit(interactable)
		

func focus(interactable: IndieBlueprintInteractable3D):
	current_interactable = interactable
	focused = true
	
	interactable.focused.emit()
	IndieBlueprintGlobalGameEvents.interactable_3d_focused.emit(interactable)
	
	
func unfocus(interactable: IndieBlueprintInteractable3D = current_interactable):
	if interactable and focused:
		current_interactable = null
		focused = false
		interacting = false

		interactable.unfocused.emit()
		IndieBlueprintGlobalGameEvents.interactable_3d_unfocused.emit(interactable)


func change_camera_to(new_camera: Camera3D) -> void:
	current_camera = new_camera


func return_to_original_camera() -> void:
	change_camera_to(origin_camera)


func activate() -> void:
	set_process(true)
	set_process_unhandled_input(true)
	

func deactivate() -> void:
	set_process(false)
	set_process_unhandled_input(false)
	

func on_canceled_interaction(_interactable: IndieBlueprintInteractable3D) -> void:
	interacting = false
	focused = false
