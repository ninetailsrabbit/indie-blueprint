class_name RunToWalkTransition extends MachineTransition


func should_transition() -> bool:
	return true
	
func on_transition() -> void:
	if from_state is Run and to_state is Walk and from_state.in_recovery:
		to_state.catching_breath_timer.start()	
