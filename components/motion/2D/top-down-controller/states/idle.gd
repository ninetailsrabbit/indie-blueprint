class_name TopDownIdle extends TopDownGround


#func enter() -> void:
	#actor.update_idle_animation(actor.motion_input.previous_input_axis_as_vector)


func physics_update(delta: float) -> void:
	if not actor.motion_input.input_axis_as_vector.is_zero_approx():
		FSM.change_state_to(TopDownWalk)
		return

	move(delta)
