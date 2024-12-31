class_name AnyToLadderClimbTransition extends MachineTransition


func should_transition() -> bool:
	if to_state is LadderClimb:
		return to_state.cooldown_timer.is_stopped()
	
	return false
