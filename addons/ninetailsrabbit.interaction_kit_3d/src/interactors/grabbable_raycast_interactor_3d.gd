## This interactor only detects the grabbables in the world as the Grabber3D is the one that make the actions
class_name GrabbableRayCastInteractor3D extends RayCast3D

var focused: bool = false
var interacting: bool = false
var current_grabbable: Grabbable3D

var global_interaction_events


func _enter_tree() -> void:
	enabled = true
	exclude_parent = true
	collide_with_areas = false
	collide_with_bodies = true
	collision_mask = 1 | InteractionKit3DPluginUtilities.layer_to_value(ProjectSettings.get_setting(InteractionKit3DPluginSettings.GrabbablesCollisionLayerSetting))
	
	if get_tree().root.has_node(InteractionKit3DPluginSettings.GlobalInteractionEventsSingleton):
		global_interaction_events = get_tree().root.get_node(InteractionKit3DPluginSettings.GlobalInteractionEventsSingleton)


func _physics_process(_delta):
	var detected_grabbable = get_collider() if is_colliding() else null
	
	if detected_grabbable is Grabbable3D and detected_grabbable.state_is_neutral():
		if current_grabbable == null and not focused:
			focus(detected_grabbable)
	else:
		if focused and not interacting and current_grabbable:
			unfocus(current_grabbable)


func focus(grabbable: Grabbable3D):
	current_grabbable = grabbable
	focused = true
	
	grabbable.focused.emit()
	
	if global_interaction_events:
		global_interaction_events.grabbable_focused.emit(grabbable)
	

func unfocus(grabbable: Grabbable3D = current_grabbable):
	if grabbable and focused:
		current_grabbable = null
		focused = false
		interacting = false
		enabled = true
		
		grabbable.unfocused.emit()
		
		if global_interaction_events:
			global_interaction_events.grabbable_unfocused.emit(grabbable)
