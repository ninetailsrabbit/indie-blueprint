class_name AnyToWallRunTransition extends MachineTransition


func should_transition() -> bool:
	if from_state is AirState:
		return from_state.wall_run_start_cooldown_timer.is_stopped()
	
	return false
