class_name ThirdPersonClickModeNeutralStateToThirdPersonClickModeMovementStateTransition extends NeutralMachineTransition


func should_transition() -> bool:
	return to_state.actor.can_move_to_next_click_position(parameters.next_position)


func on_transition():
	if to_state is ThirdPersonClickModeMovementState:
		to_state.next_position = parameters.next_position
