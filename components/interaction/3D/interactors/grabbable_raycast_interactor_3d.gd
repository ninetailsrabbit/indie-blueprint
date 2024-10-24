## This interactor only detects the grabbables in the world as the Telekinesis3D is the one that make the actions
@icon("res://components/interaction/3D/interactor_3d.svg")
class_name GrabbableRayCastInteractor3D extends RayCast3D

var focused: bool = false
var interacting: bool = false
var current_grabbable: Grabbable3D


func _enter_tree() -> void:
	enabled = true
	exclude_parent = true
	collide_with_areas = false
	collide_with_bodies = true
	collision_mask = GameGlobals.world_collision_layer | GameGlobals.grabbables_collision_layer


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

	
func unfocus(grabbable: Grabbable3D = current_grabbable):
	if grabbable and focused:
		current_grabbable = null
		focused = false
		interacting = false
		enabled = true
		
		grabbable.unfocused.emit()
