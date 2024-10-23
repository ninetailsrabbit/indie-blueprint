class_name Run extends GroundState

@export var sprint_time: float = 3.5

var in_recovery: bool = false

var sprint_timer: Timer


func ready() -> void:
	_create_sprint_timer()


func enter():
	actor.velocity.y = 0
	
	if sprint_time > 0 and is_instance_valid(sprint_timer):
		sprint_timer.start()
		
	in_recovery = false


func physics_update(delta):
	super.physics_update(delta)
	
	if actor.motion_input.input_direction.is_zero_approx() or not Input.is_action_pressed(run_input_action):
		FSM.change_state_to("Walk")
	
	accelerate(delta)
	
	detect_slide()
	detect_jump()

	stair_step_up()
	
	actor.move_and_slide()
	
	stair_step_down()


	
func _create_sprint_timer() -> void:
	if not sprint_timer:
		sprint_timer = Timer.new()
		sprint_timer.name = "RunSprintTimer"
		sprint_timer.wait_time = sprint_time
		sprint_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		sprint_timer.autostart = false
		sprint_timer.one_shot = true
		
		add_child(sprint_timer)
		sprint_timer.timeout.connect(on_sprint_timer_timeout)
		

func on_sprint_timer_timeout() -> void:
	in_recovery = true
	FSM.change_state_to("Walk")
