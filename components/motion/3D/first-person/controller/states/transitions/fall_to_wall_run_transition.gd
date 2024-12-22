class_name FallToWallRunTransition extends MachineTransition


func should_transition() -> bool:
	if from_state is Fall:
		return from_state.wall_run_start_cooldown_timer.is_stopped()
	
	return true
	
	
func on_transition() -> void:
	if from_state is Fall and to_state is WallRun:
		from_state.wall_run_start_cooldown_timer.stop()
