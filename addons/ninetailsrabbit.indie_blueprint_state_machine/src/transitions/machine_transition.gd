class_name IndieBlueprintMachineTransition

var from_state: IndieBlueprintMachineState
var to_state: IndieBlueprintMachineState

var parameters: Dictionary = {}

func should_transition() -> bool:
	return true
	
func on_transition():
	pass
