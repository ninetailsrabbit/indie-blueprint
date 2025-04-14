class_name FirstPersonCrouchState extends FirstPersonGroundState


func enter() -> void:
	crouch_animation()


func exit(next_state: IndieBlueprintMachineState) -> void:
	if not next_state is FirstPersonCrawlState:
		crouch_exit_animation()


func physics_update(delta):
	super.physics_update(delta)
	
	if crouch_tween == null or (crouch_tween and not crouch_tween.is_running()):
		if not Input.is_action_pressed(crouch_input_action) and not actor.ceil_shape_cast.is_colliding():
			if actor.motion_input.input_direction.is_zero_approx():
				FSM.change_state_to(FirstPersonIdleState)
			else:
				FSM.change_state_to(FirstPersonWalkState)
				
	accelerate(delta)
	
	if not actor.ceil_shape_cast.is_colliding():
		detect_jump()
	
	detect_crawl()
	
	stair_step_up()
	actor.move_and_slide()
	stair_step_down()
