class_name AnyToFirstPersonWallJumpStateTransition extends IndieBlueprintMachineTransition


func should_transition() -> bool:
	return from_state is FirstPersonAirState \
		and to_state is FirstPersonWallJumpState \
		and parameters.has("wall_normal")


func on_transition() -> void:
	to_state.current_wall_normal = parameters.wall_normal
