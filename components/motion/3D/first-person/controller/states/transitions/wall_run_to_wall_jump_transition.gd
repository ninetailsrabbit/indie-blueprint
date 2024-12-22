class_name WallRunToWallJumpTransition extends MachineTransition


func on_transition() -> void:
	if from_state is WallRun and to_state is WallJump:
		if from_state.wall_run_cooldown > 0 and is_instance_valid(from_state.wall_run_cooldown_timer):
			from_state.wall_run_cooldown_timer.start(from_state.wall_run_cooldown)
	
