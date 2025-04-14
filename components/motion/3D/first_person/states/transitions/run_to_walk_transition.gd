class_name FirstPersonRunStateToFirstPersonWalkTransition extends IndieBlueprintMachineTransition


func should_transition() -> bool:
	return true


func on_transition() -> void:
	if from_state is FirstPersonRunState and to_state is FirstPersonWalkState and from_state.in_recovery:
		to_state.catching_breath_timer.start()
