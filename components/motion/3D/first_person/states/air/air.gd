class_name FirstPersonAirState extends IndieBlueprintMachineState

@export var actor: IndieBlueprintFirstPersonController
@export_group("Parameters")
@export var gravity_force: float = 9.8
@export var air_speed: float = 3.0
@export var air_side_speed: float = 2.5
@export var air_acceleration: float = 15.0
@export var air_friction: float = 10.0
@export var maximum_fall_velocity: float = 25.0
## When enter any air state (except wall ones), the player cannot wall run until this time passed
@export var wall_run_start_cooldown: float = 0.5
@export_group("Input actions")
@export var jump_input_action: StringName = InputControls.JumpAction
@export var dash_input_action: StringName = InputControls.DashAction

var wall_run_start_cooldown_timer: Timer
var current_air_speed: float = 0.0
var gravity_enabled: bool = true
var current_gravity_force: float = gravity_force


func _ready() -> void:
	_create_wall_run_start_cooldown_timer()
	

func physics_update(delta: float):
	apply_gravity(current_gravity_force, delta)
	air_move(delta)
	limit_fall_velocity()


func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	if gravity_enabled:
		actor.velocity += IndieBlueprintVectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta


func change_gravity(new_force: float) -> void:
	current_gravity_force = new_force


func reset_gravity() -> void:
	current_gravity_force = gravity_force
	
	
func enable_gravity() -> void:
	gravity_enabled = true


func disable_gravity() -> void:
	gravity_enabled = false


func air_move(delta: float = get_physics_process_delta_time()) -> void:
	accelerate(delta)


func accelerate(delta: float = get_physics_process_delta_time()) -> void:
	var direction = actor.motion_input.world_coordinate_space_direction
	
	#if direction.is_zero_approx():
		#return
		
	current_air_speed = get_speed()
	
	if air_acceleration > 0:
		actor.velocity.x = lerp(actor.velocity.x, direction.x * current_air_speed, clampf(air_acceleration * delta, 0, 1.0))
		actor.velocity.z = lerp(actor.velocity.z, direction.z * current_air_speed, clampf(air_acceleration * delta, 0, 1.0))
	else:
		actor.velocity = Vector3(
			actor.velocity.x * direction.x * current_air_speed, 
			actor.velocity.y, 
			actor.velocity.x * direction.z * current_air_speed 
		)
		

func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	if air_friction > 0:
		actor.velocity = lerp(actor.velocity, Vector3(0, actor.velocity.y, 0), clampf(air_friction * delta, 0, 1.0))
	else:
		actor.velocity = Vector3(0, actor.velocity.y, 0)


func get_speed() -> float:
	return air_side_speed if actor.motion_input.input_direction in IndieBlueprintVectorHelper.horizontal_directions_v2 else air_speed


func detect_jump() -> void:
	if actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		FSM.change_state_to(FirstPersonJumpState)


func detect_dash() -> void:
	if actor.dash \
		and not actor.motion_input.world_coordinate_space_direction.is_zero_approx() \
		and InputMap.has_action(dash_input_action) \
		and Input.is_action_just_pressed(dash_input_action):
			
		FSM.change_state_to(FirstPersonDashState)
	

#func detect_wall_jump() -> void:
	#if wall_run_start_cooldown_timer.is_stopped() and actor.wall_detected() and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		#FSM.change_state_to(WallJump)
#
#
#func detect_wall_run() -> void:
	#if actor.wall_detected():
		#FSM.change_state_to(WallRun)


#func detect_swim() -> void:
	#if FSM.states.has("Swim") and actor.swim:
		#var swim_state: Swim = FSM.states["Swim"] as Swim
		#
		#if swim_state.eyes.global_position.y <= swim_state.water_height:
			#FSM.change_state_to(Swim)
#

func limit_fall_velocity() -> void:
	var up_direction_opposite = IndieBlueprintVectorHelper.up_direction_opposite_vector3(actor.up_direction)
	
	if up_direction_opposite in [Vector3.DOWN, Vector3.UP]:
		actor.velocity.y = max(sign(up_direction_opposite.y) * maximum_fall_velocity, actor.velocity.y)
	else:
		actor.velocity.x = max(sign(up_direction_opposite.x) * maximum_fall_velocity, actor.velocity.x)
		
	
func _create_wall_run_start_cooldown_timer() -> void:
	if wall_run_start_cooldown_timer == null:
		wall_run_start_cooldown_timer = IndieBlueprintTimeHelper.create_physics_timer(maxf(0.05, wall_run_start_cooldown), false, true)
		wall_run_start_cooldown_timer.name = "WallRunStartCooldownTimer"

		add_child(wall_run_start_cooldown_timer)
