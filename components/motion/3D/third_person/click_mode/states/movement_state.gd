class_name ThirdPersonClickModeMovementState extends ThirdPersonClickModeBaseState

@export var speed: float = 5.0


var direction: Vector3
var next_position: Vector3


func handle_unhandled_input(event: InputEvent) -> void:
	if IndieBlueprintInputHelper.is_mouse_left_click(event):
		_handle_click_movement()
	

func enter() -> void:
	if not actor.smooth_rotation:
		actor.look_at(
			Vector3(next_position.x, actor.global_position.y, next_position.z),
			Vector3.UP
		)


func physics_update(delta: float) -> void:
	actor.navigation_agent_3d.target_position = next_position
	direction = actor.global_position.direction_to(actor.navigation_agent_3d.get_next_path_position())
	
	if actor.smooth_rotation:
		actor.rotation.y = lerp_angle(actor.rotation.y, atan2(-direction.x, -direction.z), delta * actor.smooth_rotation_lerp_speed)
	
	actor.velocity = direction * speed

	actor.move_and_slide()
	
	if actor.navigation_agent_3d.is_navigation_finished():
		FSM.change_state_to(ThirdPersonClickModeNeutralState)


func _handle_click_movement():
	var raycast_result: RaycastResult = IndieBlueprintCamera3DHelper\
		.project_raycast_to_mouse(actor.camera)
	
	if raycast_result.collider and raycast_result.collider != self:
		var _next_position: Vector3 = NavigationServer3D\
			.map_get_closest_point(actor.get_world_3d().navigation_map, raycast_result.position)
		
		if actor.can_change_click_position_while_moving \
			and actor.can_move_to_next_click_position(_next_position):
				
			next_position = _next_position
