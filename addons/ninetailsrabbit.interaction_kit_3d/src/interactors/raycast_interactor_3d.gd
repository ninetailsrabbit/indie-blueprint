class_name RayCastInteractor3D extends RayCast3D

@export var interact_input_action: StringName = &"interact"
@export var cancel_interact_input_action: StringName = &"cancel_interact"
@export var scan_input_action: StringName = &"interact"


var current_interactable: Interactable3D
var focused: bool = false
var interacting: bool = false
var global_interaction_events


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
		
		
	if InputMap.has_action(scan_input_action) \
		and Input.is_action_just_pressed(scan_input_action) \
		and current_interactable \
		and not interacting:
	
			scan(current_interactable)
		

func _enter_tree():
	enabled = true
	exclude_parent = true
	collide_with_areas = true
	collide_with_bodies = true
	collision_mask = 1 | InteractionKit3DPluginUtilities.layer_to_value(ProjectSettings.get_setting(InteractionKit3DPluginSettings.InteractablesCollisionLayerSetting)) | InteractionKit3DPluginUtilities.layer_to_value(ProjectSettings.get_setting(InteractionKit3DPluginSettings.GrabbablesCollisionLayerSetting)) 
	
	if get_tree().root.has_node(InteractionKit3DPluginSettings.GlobalInteractionEventsSingleton):
		global_interaction_events = get_tree().root.get_node(InteractionKit3DPluginSettings.GlobalInteractionEventsSingleton)


func _physics_process(_delta):
	var detected_interactable = get_collider() if is_colliding() else null

	if detected_interactable is Interactable3D:
		if current_interactable == null and not focused:
			focus(detected_interactable)
	else:
		if focused and not interacting and current_interactable:
			unfocus(current_interactable)


func scan(interactable: Interactable3D = current_interactable):
	if interactable and not interacting and interactable.can_be_interacted and interactable.scannable:
		enabled = false
		interacting = interactable.lock_player_on_interact
		
		interactable.scanned.emit()
		
		if global_interaction_events:
			global_interaction_events.interactable_scanned.emit(interactable)
		
		interactable._remove_outline_shader()
		await get_tree().process_frame
		
		ScanInteractableLayer.scan(interactable.target_scannable_object)
		ScanInteractableLayer.scan_ended.connect(
			func(_scanned_object: Node3D): 
				interacting = false
				focused = false
				enabled = true
				current_interactable = null
				, CONNECT_ONE_SHOT)
		
	

func interact(interactable: Interactable3D = current_interactable):
	if interactable and not interacting and interactable.can_be_interacted:
		enabled = false
		interacting = interactable.lock_player_on_interact
		
		interactable.interacted.emit()
		
		if global_interaction_events:
			global_interaction_events.interactable_interacted.emit(interactable)


func cancel_interact(interactable: Interactable3D = current_interactable):
	if interactable:
		interacting = false
		focused = false
		enabled = true
		current_interactable = null
		
		interactable.canceled_interaction.emit()
		
		if global_interaction_events:
			global_interaction_events.interactable_canceled_interaction.emit(interactable)


func focus(interactable: Interactable3D):
	current_interactable = interactable
	focused = true
	
	interactable.focused.emit()
	
	if global_interaction_events:
		global_interaction_events.interactable_focused.emit(interactable)


func unfocus(interactable: Interactable3D = current_interactable):
	if interactable and focused:
		current_interactable = null
		focused = false
		interacting = false
		enabled = true
		
		interactable.unfocused.emit()
		
		if global_interaction_events:
			global_interaction_events.interactable_unfocused.emit(interactable)
