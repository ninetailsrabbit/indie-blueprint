@icon("res://components/interaction/3D/interactors/interactor.svg")
class_name IndieBlueprintRayCastInteractor3D extends RayCast3D

@export var interact_input_action: StringName = InputControls.Interact
@export var cancel_interact_input_action: StringName = InputControls.CancelInteraction


var current_interactable: IndieBlueprintInteractable3D
var focused: bool = false
var interacting: bool = false


func _unhandled_input(_event: InputEvent):
	if InputMap.has_action(interact_input_action) \
		and Input.is_action_just_pressed(interact_input_action) \
		and current_interactable \
		and not interacting:
			
		interact(current_interactable)
		
	
	if InputMap.has_action(cancel_interact_input_action) \
		and Input.is_action_just_pressed(cancel_interact_input_action) \
		and current_interactable:
			
		cancel_interact(current_interactable)


func _enter_tree():
	enabled = true
	exclude_parent = true
	collide_with_areas = true
	collide_with_bodies = true
	collision_mask = IndieBlueprintGameGlobals.world_collision_layer | IndieBlueprintGameGlobals.interactables_collision_layer | IndieBlueprintGameGlobals.grabbables_collision_layer
	

func _physics_process(_delta):
	var detected_interactable = get_collider() if is_colliding() else null

	if detected_interactable is IndieBlueprintInteractable3D:
		if current_interactable == null and not focused:
			focus(detected_interactable)
	else:
		if focused and not interacting and current_interactable:
			unfocus(current_interactable)


func interact(interactable: IndieBlueprintInteractable3D = current_interactable):
	if interactable and not interacting and interactable.can_be_interacted:
		enabled = false
		interacting = interactable.lock_player_on_interact
		
		interactable.interacted.emit()
		IndieBlueprintGlobalGameEvents.interactable_3d_interacted.emit(interactable)


func cancel_interact(interactable: IndieBlueprintInteractable3D = current_interactable):
	if interactable:
		interacting = false
		focused = false
		enabled = true
		current_interactable = null
		
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
		enabled = true
		
		interactable.unfocused.emit()
		IndieBlueprintGlobalGameEvents.interactable_3d_unfocused.emit(interactable)
