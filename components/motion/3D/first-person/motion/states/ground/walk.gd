class_name Walk extends GroundState

@export var catching_breath_recovery_time: float = 3.0

var catching_breath_timer: Timer


func ready() -> void:
	_create_catching_breath_timer()
	
	
func enter():
	actor.velocity.y = 0


func physics_update(delta):
	super.physics_update(delta)
	
	if actor.motion_input.input_direction.is_zero_approx():
		FSM.change_state_to("Idle")
	
	accelerate(delta)
	
	detect_jump()
	detect_run()
	detect_crouch()
	
	stair_step_up()
	
	actor.move_and_slide()
	
	stair_step_down()


func _create_catching_breath_timer() -> void:
	if not catching_breath_timer:
		catching_breath_timer = Timer.new()
		catching_breath_timer.name = "RunCatchingBreathTimer"
		catching_breath_timer.wait_time = catching_breath_recovery_time
		catching_breath_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		catching_breath_timer.autostart = false
		catching_breath_timer.one_shot = true
		
		add_child(catching_breath_timer)
