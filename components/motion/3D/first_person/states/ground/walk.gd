class_name FirstPersonWalkState extends FirstPersonGroundState

@export var catching_breath_recovery_time: float = 3.0

var catching_breath_timer: Timer


func ready() -> void:
	_create_catching_breath_timer()
	
	
func enter():
	super.enter()
	
	actor.velocity.y = 0


func physics_update(delta):
	super.physics_update(delta)
		
	if actor.motion_input.input_direction.is_zero_approx():
		FSM.change_state_to(FirstPersonIdleState)
	
	accelerate(delta)
	
	detect_jump()
	detect_run()
	detect_crouch()
	detect_dash()
	
	stair_step_up()
	actor.move_and_slide()
	stair_step_down()
	
	actor.footsteps_manager.footstep(0.4)


func _create_catching_breath_timer() -> void:
	if not catching_breath_timer:
		catching_breath_timer = IndieBlueprintTimeHelper.create_physics_timer(catching_breath_recovery_time, false, true)
		catching_breath_timer.name = "RunCatchingBreathTimer"
		add_child(catching_breath_timer)
