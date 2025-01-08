@icon("res://components/interaction/2D/interactor_2d.svg")
class_name AreaInteractor2D extends Area2D

@export var maximum_detection_distance: float = 25.0
@export var interact_input_action: StringName = InputControls.Interact
@export var cancel_interact_input_action: StringName = InputControls.CancelInteraction


var current_interactable: Interactable2D
var focused: bool = false
var interacting: bool = false


func _unhandled_input(_event: InputEvent):
	if InputMap.has_action(interact_input_action) && Input.is_action_just_pressed(interact_input_action) and current_interactable and not interacting:
		interact(current_interactable)
		
	
	if InputMap.has_action(cancel_interact_input_action) && Input.is_action_just_pressed(cancel_interact_input_action) and current_interactable:
		cancel_interact(current_interactable)


func _enter_tree():
	priority = 1
	collision_layer = 0
	collision_mask = GameGlobals.world_collision_layer | GameGlobals.interactables_collision_layer | GameGlobals.grabbables_collision_layer
	monitoring = true
	monitorable = false


func _physics_process(_delta):
	var detected_interactables = get_overlapping_areas().filter(func(area: Area2D): return area is Interactable2D)
	detected_interactables = NodePositioner.get_nearest_nodes_sorted_by_distance(global_position, detected_interactables, 0.0, maximum_detection_distance)
	
	if detected_interactables.size() > 0:
		if current_interactable == null and not focused:
			focus(detected_interactables.front())
	else:
		if focused and not interacting and current_interactable:
			
			unfocus(current_interactable)


func interact(interactable: Interactable2D = current_interactable):
	if interactable and not interacting:
		interacting = interactable.lock_player_on_interact
		
		interactable.interacted.emit()


func cancel_interact(interactable: Interactable2D = current_interactable):
	if interactable:
		interacting = false
		focused = false
		current_interactable = null
		
		interactable.canceled_interaction.emit()


func focus(interactable: Interactable2D):
	current_interactable = interactable
	focused = true
	
	interactable.focused.emit()


func unfocus(interactable: Interactable2D = current_interactable):
	if interactable and focused:
		current_interactable = null
		focused = false
		interacting = false
		
		interactable.unfocused.emit()
