class_name TopDownWalk extends TopDownGround

	
func physics_update(delta: float) -> void:
	if actor.motion_input.input_axis_as_vector.is_zero_approx():
		FSM.change_state_to(TopDownIdle)
		return
		
	#actor.update_walk_animation(actor.motion_input.input_axis_as_vector)
	move(delta)
	detect_dash()
