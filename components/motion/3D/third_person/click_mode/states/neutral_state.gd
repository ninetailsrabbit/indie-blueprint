class_name ThirdPersonClickModeNeutralState extends ThirdPersonClickModeBaseState


func handle_unhandled_input(event: InputEvent) -> void:
	if IndieBlueprintInputHelper.is_mouse_left_click(event) \
		and IndieBlueprintInputHelper.is_mouse_visible():
			
		_handle_click_movement()
		
	if IndieBlueprintInputHelper.is_mouse_right_click(event):
		FSM.change_state_to(ThirdPersonClickModeProjectilePredictionState)
		

func _handle_click_movement() -> void:
	var raycast_result: RaycastResult = IndieBlueprintCamera3DHelper\
		.project_raycast_to_mouse(actor.camera)
	

	var next_position: Vector3 = NavigationServer3D\
		.map_get_closest_point(actor.get_world_3d().navigation_map, raycast_result.position)
	
	if actor.can_move_to_next_click_position(next_position):
		FSM.change_state_to(ThirdPersonClickModeMovementState, {"next_position": next_position})
