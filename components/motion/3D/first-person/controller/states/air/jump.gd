class_name Jump extends AirState

@export var jump_times: int = 1
@export var height_reduced_by_jump = 0.2
@export var shorten_jump_on_input_release = true

@export var jump_height: float = 2.5:
	get:
		return jump_height
	set(value):
		jump_height = value
		
		jump_velocity = calculate_jump_velocity(jump_height, jump_peak_time)
		jump_gravity = calculate_jump_gravity(jump_height, jump_peak_time)
		fall_gravity = calculate_fall_gravity(jump_height, jump_fall_time)
		
@export var jump_peak_time: float = 0.55:
	get:
		return jump_peak_time
	set(value):
		jump_peak_time = value
		
		jump_velocity = calculate_jump_velocity(jump_height, jump_peak_time)
		jump_gravity = calculate_jump_gravity(jump_height, jump_peak_time)
		air_speed = calculate_air_speed(jump_distance, jump_peak_time, jump_fall_time)
		
		
@export var jump_fall_time: float = 0.48:
	get:
		return jump_fall_time
	set(value):
		jump_fall_time = value
		
		fall_gravity = calculate_fall_gravity(jump_height, jump_fall_time)
		air_speed = calculate_air_speed(jump_distance, jump_peak_time, jump_fall_time)
		
@export var jump_distance: float = 4.0:
	get:
		return jump_distance
	set(value):
		jump_distance = value
		
		air_speed = calculate_air_speed(jump_distance, jump_peak_time, jump_fall_time)


var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

var jump_count: int = 0
var jump_horizontal_boost = 0.0
var jump_vertical_boost = 0.0

var last_jumped_position: Vector3 = Vector3.ZERO


func ready():
	jump_velocity = calculate_jump_velocity(jump_height, jump_peak_time)
	jump_gravity = calculate_jump_gravity(jump_height, jump_peak_time)
	fall_gravity = calculate_fall_gravity(jump_height, jump_fall_time)
	air_speed = calculate_air_speed(jump_distance, jump_peak_time, jump_fall_time)
	
	
func enter():
	apply_jump()
	actor.move_and_slide()


func exit(_next_state: MachineState):
	jump_count = 0
	jump_horizontal_boost = 0
	jump_vertical_boost = 0
	last_jumped_position = Vector3.ZERO
	

func physics_update(delta: float):
	apply_gravity(get_gravity(), delta)
	air_move(delta)
	
	if Input.is_action_just_pressed(jump_input_action) and jump_count < jump_times:
		apply_jump()
		
	if shorten_jump_on_input_release and Input.is_action_just_released(jump_input_action):
		shorten_jump()
		
	if actor.is_grounded:
		if actor.motion_input.input_direction.is_zero_approx():
			FSM.change_state_to("Idle")
		else:
			FSM.change_state_to("Walk")
			
	
	detect_fall_after_jump_fall_time_passed()
	
	actor.move_and_slide()


func apply_jump() -> void:
	last_jumped_position = actor.position
	jump_count += 1
	
	var up_direction: Vector3 = actor.up_direction
	
	var _jump_velocity = calculate_jump_velocity(jump_height - (jump_count * height_reduced_by_jump), jump_peak_time)
	
	if up_direction in [Vector3.DOWN, Vector3.UP]:
		actor.velocity.y = sign(up_direction.y) * _jump_velocity
	elif up_direction in [Vector3.RIGHT, Vector3.LEFT]:
		actor.velocity.x = sign(up_direction.x) * _jump_velocity


func get_gravity() -> float:
	var up_direction_opposite: Vector3 = VectorHelper.up_direction_opposite_vector3(actor.up_direction)
	
	if up_direction_opposite.is_equal_approx(Vector3.DOWN):
		return jump_gravity if actor.velocity.y > 0 else fall_gravity
	elif up_direction_opposite.is_equal_approx(Vector3.UP):
		return jump_gravity if actor.velocity.y < 0 else fall_gravity
	elif up_direction_opposite.is_equal_approx(Vector3.RIGHT):
		return jump_gravity if actor.velocity.x < 0 else fall_gravity
	elif up_direction_opposite.is_equal_approx(Vector3.LEFT):
		return jump_gravity if actor.velocity.x > 0 else fall_gravity
	else:
		return 0.0


func shorten_jump(factor: float = 2.0) -> void:
	var new_jump_velocity = jump_velocity / factor
	
	if(actor.velocity.y > new_jump_velocity):
		actor.velocity.y = new_jump_velocity


func detect_fall_after_jump_fall_time_passed() -> void:
	var up_direction_opposite: Vector3 = VectorHelper.up_direction_opposite_vector3(actor.up_direction)
	
	if up_direction_opposite.is_equal_approx(Vector3.DOWN) and actor.position.y < last_jumped_position.y \
	or  up_direction_opposite.is_equal_approx(Vector3.UP) and actor.position.y > last_jumped_position.y \
	or up_direction_opposite.is_equal_approx(Vector3.RIGHT) and actor.position.x > last_jumped_position.x \
	or up_direction_opposite.is_equal_approx(Vector3.LEFT) and actor.position.x < last_jumped_position.x:
		FSM.change_state_to("Fall")
	
	
	
#region Calculations
func calculate_jump_gravity(height: float, peak_time: float) -> float:
	return (2.0 * height) / pow(peak_time, 2)


func calculate_fall_gravity(height: float, fall_time: float) -> float:
	return (2.0 * height) / pow(fall_time, 2)
	

func calculate_jump_velocity(height: float, peak_time: float) -> float:
	return calculate_jump_gravity(height, peak_time) * peak_time


func calculate_air_speed(distance: float, peak_time: float, fall_time: float) -> float:
	return  distance / (peak_time + fall_time)
#endregion
