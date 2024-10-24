class_name AirState extends MachineState


@export var actor: FirstPersonController
@export_group("Parameters")
@export var gravity_force: float = 9.8
@export var air_speed: float = 3.0
@export var air_side_speed: float = 2.5
@export var air_acceleration: float = 15.0
@export var air_friction: float = 10.0
@export var maximum_fall_velocity: float = 25.0
@export_group("Input actions")
@export var jump_input_action: String = "jump"

var current_air_speed: float = 0.0

func physics_update(delta: float):
	apply_gravity(gravity_force, delta)
	air_move(delta)
	limit_fall_velocity()


func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	actor.velocity += VectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta


func air_move(delta: float = get_physics_process_delta_time()) -> void:
	if not actor.motion_input.input_direction.is_zero_approx():
				accelerate(delta)


func accelerate(delta: float = get_physics_process_delta_time()) -> void:
	var direction = actor.motion_input.world_coordinate_space_direction
	
	current_air_speed = get_speed()
	
	if air_acceleration > 0:
		actor.velocity.x = lerp(actor.velocity.x, direction.x * current_air_speed, clamp(air_acceleration * delta, 0, 1.0))
		actor.velocity.z = lerp(actor.velocity.z, direction.z * current_air_speed, clamp(air_acceleration * delta, 0, 1.0))
	
	else:
		actor.velocity = Vector3(
			actor.velocity.x * direction.x * current_air_speed, 
			actor.velocity.y, 
			actor.velocity.x * direction.z * current_air_speed 
		)


func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	if air_friction > 0:
		actor.velocity = lerp(actor.velocity, Vector3(0, actor.velocity.y, 0), clamp(air_friction * delta, 0, 1.0))
	else:
		actor.velocity = Vector3(0, actor.velocity.y, 0)


func get_speed() -> float:
	return air_side_speed if actor.motion_input.input_direction in VectorHelper.horizontal_directions_v2 else air_speed


func detect_jump() -> void:
	if actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		FSM.change_state_to("Jump")


func detect_swim() -> void:
	if FSM.states.has("Swim") and actor.swim:
		var swim_state: Swim = FSM.states["Swim"] as Swim
		
		if swim_state.eyes.global_position.y <= swim_state.water_height:
			FSM.change_state_to("Swim")


func limit_fall_velocity() -> void:
	var up_direction_opposite = VectorHelper.up_direction_opposite_vector3(actor.up_direction)
	
	if up_direction_opposite in [Vector3.DOWN, Vector3.UP]:
		actor.velocity.y = max(sign(up_direction_opposite.y) * maximum_fall_velocity, actor.velocity.y)
	else:
		actor.velocity.x = max(sign(up_direction_opposite.x) * maximum_fall_velocity, actor.velocity.x)
		
	
