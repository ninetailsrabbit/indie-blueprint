class_name Fall extends AirState

@export var edge_gap_auto_jump: float = 0.45
@export var coyote_time: bool = true
@export var coyote_time_frames = 20
@export var jump_input_buffer: bool = true
@export var jump_input_buffer_time_frames = 30


var jump_requested: bool = false
var current_coyote_time_frames: int = 0:
	get:
		return current_coyote_time_frames
	set(value):
		current_coyote_time_frames = max(0, value)
		
var current_jump_input_buffer_time_frames: int = 0:
	get:
		return current_jump_input_buffer_time_frames
	set(value):
		current_jump_input_buffer_time_frames = max(0, value)


func enter():
	jump_requested = false
	current_coyote_time_frames = coyote_time_frames
	current_jump_input_buffer_time_frames = jump_input_buffer_time_frames
	
	if FSM.last_state() is GroundState:
		FSM.last_state().stair_stepping = false


func physics_update(delta: float):
	super.physics_update(delta)
	
	jump_requested = actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action)
	current_coyote_time_frames -= 1
	current_jump_input_buffer_time_frames -= 1
	
	if jump_requested and _coyote_time_is_active():
		FSM.change_state_to("Jump")
		
	elif (not actor.was_grounded and actor.is_grounded) or actor.is_on_floor():
		if jump_requested and _jump_input_buffer_is_active():
			FSM.change_state_to("Jump")
		else:
			if actor.motion_input.input_direction.is_zero_approx():
				FSM.change_state_to("Idle")
			else:
				FSM.change_state_to("Walk")
			
	detect_swim()
	actor.move_and_slide()


#region Detectors
func _coyote_time_is_active() -> bool:
	return coyote_time and current_coyote_time_frames > 0 and FSM.last_state() is GroundState

func _jump_input_buffer_is_active() -> bool:
	return jump_input_buffer and current_jump_input_buffer_time_frames > 0
#endregion
