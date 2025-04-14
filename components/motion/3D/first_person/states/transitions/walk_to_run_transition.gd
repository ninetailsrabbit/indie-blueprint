class_name FirstPersonWalkStateToFirstPersonRunStateTransition extends IndieBlueprintMachineTransition


func should_transition() -> bool:
	if from_state is FirstPersonWalkState and to_state is FirstPersonRunState:
		return from_state.actor.run and from_state.catching_breath_timer.is_stopped()
	
	return false
	
