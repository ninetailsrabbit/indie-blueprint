class_name JumpToWallRunTransition extends MachineTransition


func should_transition() -> bool:
	if from_state is Jump:
		return from_state.wall_run_start_cooldown_timer.is_stopped()
	
	return true
	
	
func on_transition() -> void:
	if from_state is Jump and to_state is WallRun:
		from_state.wall_run_start_cooldown_timer.stop()
