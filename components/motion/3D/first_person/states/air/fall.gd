class_name FirstPersonFallState extends FirstPersonAirState

@export var edge_gap_auto_jump: float = 0.45
@export var coyote_time: bool = true
@export var coyote_time_frames = 20
@export var jump_input_buffer: bool = true
@export var jump_input_buffer_time_frames: int = 30


var jump_requested: bool = false
var current_coyote_time_frames: int = 0:
	set(value):
		current_coyote_time_frames = maxi(0, value)
		
var current_jump_input_buffer_time_frames: int = 0:
	set(value):
		current_jump_input_buffer_time_frames = maxi(0, value)


func enter():
	jump_requested = false
	current_coyote_time_frames = coyote_time_frames
	current_jump_input_buffer_time_frames = jump_input_buffer_time_frames
	
	if FSM.last_state() is FirstPersonGroundState:
		FSM.last_state().stair_stepping = false
	
	wall_run_start_cooldown_timer.start()
	
	detect_dash()
	
	actor.velocity += actor.global_transform.basis.z * edge_gap_auto_jump
	actor.move_and_slide()


func exit(next_state: IndieBlueprintMachineState) -> void:
	if next_state is FirstPersonGroundState:
		actor.footsteps_manager.footstep(0.2, FootstepSound.FootstepType.Land)


func physics_update(delta: float):
	super.physics_update(delta)
	
	jump_requested = actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action)
	current_coyote_time_frames -= 1
	current_jump_input_buffer_time_frames -= 1
	
	if jump_requested and _coyote_time_is_active():
		FSM.change_state_to(FirstPersonJumpState)
		
	elif (not actor.was_grounded and actor.is_grounded) or actor.is_on_floor():
		if jump_requested and _jump_input_buffer_is_active():
			pass
			FSM.change_state_to(FirstPersonJumpState)
		else:
			if actor.motion_input.input_direction.is_zero_approx():
				FSM.change_state_to(FirstPersonIdleState)
			else:
				FSM.change_state_to(FirstPersonWalkState)
			
	#detect_swim()
	#detect_wall_jump()
	#detect_wall_run()

	actor.move_and_slide()


#region Detectors
func _coyote_time_is_active() -> bool:
	return coyote_time and current_coyote_time_frames > 0 and FSM.last_state() is FirstPersonGroundState

func _jump_input_buffer_is_active() -> bool:
	return jump_input_buffer and current_jump_input_buffer_time_frames > 0
#endregion
