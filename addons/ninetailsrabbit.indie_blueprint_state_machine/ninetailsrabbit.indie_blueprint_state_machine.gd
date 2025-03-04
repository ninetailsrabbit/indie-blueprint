@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("IndieBlueprintMachineState", "Node", preload("src/machine_state.gd"), preload("icons/state.svg"))
	add_custom_type("IndieBlueprintFiniteStateMachine", "Node", preload("src/finite-state-machine.gd"), preload("icons/fsm.svg"))
	
	
func _exit_tree() -> void:
	remove_custom_type("IndieBlueprintMachineState")
	remove_custom_type("IndieBlueprintFiniteStateMachine")
