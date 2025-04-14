class_name MotionInput

var move_right_action: StringName = &"move_right"
var move_left_action: StringName = &"move_left"
var move_forward_action: StringName = &"move_forward"
var move_back_action: StringName = &"move_back"

## Right joystick support
var up_motion_action: StringName = &"up_motion"
var down_motion_action: StringName = &"down_motion"
var left_motion_action: StringName = &"left_motion"
var right_motion_action: StringName = &"right_motion"

var actor: Node
var deadzone: float = 0.2:
	set(value):
		deadzone = clampf(value, 0.0, 1.0)

#region Current input
var input_direction: Vector2
var input_direction_deadzone_square_shape: Vector2
var input_direction_horizontal_axis: float
var input_direction_vertical_axis: float
var input_axis_as_vector: Vector2

## Right joystick support
var input_right_motion_horizontal_axis: float
var input_right_motion_vertical_axis: float
var input_right_motion_axis_as_vector: Vector2
var input_right_motion_as_vector: Vector2

var input_direction_horizontal_axis_applied_deadzone: float
var input_direction_vertical_axis_applied_deadzone: float
var input_joy_direction_left: Vector2
var input_joy_direction_right: Vector2
var world_coordinate_space_direction: Vector3
#endregion

#region Previous input
var previous_input_direction: Vector2
var previous_input_direction_deadzone_square_shape: Vector2
var previous_input_direction_horizontal_axis: float
var previous_input_direction_vertical_axis: float
var previous_input_axis_as_vector: Vector2

## Right joystick support
var previous_input_right_motion_horizontal_axis: float
var previous_input_right_motion_vertical_axis: float
var previous_input_right_motion_as_vector: Vector2
var previous_input_right_motion_axis_as_vector: Vector2

var previous_input_direction_horizontal_axis_applied_deadzone: float
var previous_input_direction_vertical_axis_applied_deadzone: float
var previous_input_joy_direction_left: Vector2
var previous_input_joy_direction_right: Vector2
var previous_world_coordinate_space_direction: Vector3
#endregion


var current_device_id: int = 0

func _init(_actor: Node3D = null, _deadzone: float = deadzone):
	if _actor == null:
		push_warning("MotionInput: The actor as Node3D is not set, the world_coordinate_space_direction will return Vector3.ZERO when retrieved")
	
	actor = _actor
	deadzone = _deadzone
	
	Input.joy_connection_changed.connect(on_joy_connection_changed)


func update():
	_update_previous_directions()
	# This handles deadzone in a correct way for most use cases. The resulting deadzone will have a circular shape as it generally should.
	input_direction = get_motion_input()
	
	if actor is Node3D:
		world_coordinate_space_direction = actor.transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized()
	
	input_direction_deadzone_square_shape = Vector2(
		Input.get_action_strength(move_right_action) - Input.get_action_strength(move_left_action),
		Input.get_action_strength(move_back_action) - Input.get_action_strength(move_forward_action)
	).limit_length(deadzone)
	
	input_direction_horizontal_axis = Input.get_axis(move_left_action, move_right_action)
	input_direction_vertical_axis = Input.get_axis(move_forward_action, move_back_action)
	input_axis_as_vector = _input_axis_as_vector()
	
	input_right_motion_horizontal_axis = Input.get_axis(left_motion_action, right_motion_action)
	input_right_motion_vertical_axis = Input.get_axis(up_motion_action, down_motion_action)
	input_right_motion_axis_as_vector = Vector2(input_right_motion_horizontal_axis, input_right_motion_vertical_axis)
	input_right_motion_as_vector = get_right_joystick_input()
	
	_calculate_joystick_movement()
	
	input_direction_horizontal_axis_applied_deadzone = input_direction_horizontal_axis * (1.0 - deadzone)
	input_direction_vertical_axis_applied_deadzone = input_direction_vertical_axis * (1.0 - deadzone)


func get_motion_input() -> Vector2:
	return Input.get_vector(move_left_action, move_right_action, move_forward_action, move_back_action)
	
	
func get_right_joystick_input() -> Vector2:
	return Input.get_vector(left_motion_action, right_motion_action, up_motion_action, down_motion_action, deadzone)
	
	
func _input_axis_as_vector() -> Vector2:
	var input: Vector2 = Vector2(input_direction_horizontal_axis, input_direction_vertical_axis)
	
	if input.normalized().is_equal_approx(Vector2.DOWN):
		return Vector2.DOWN
		
	elif input.normalized().is_equal_approx(Vector2.UP):
		return Vector2.UP
		
	elif input.normalized().is_equal_approx(Vector2.RIGHT):
		return Vector2.RIGHT
		
	elif input.normalized().is_equal_approx(Vector2.LEFT):
		return Vector2.LEFT
		
	elif sign(input.x) == 1 and sign(input.y) == -1:
		return Vector2.RIGHT + Vector2.UP
		
	elif sign(input.x) == -1 and sign(input.y) == -1:
		return Vector2.LEFT + Vector2.UP
		
	elif sign(input.x) == 1 and sign(input.y) == 1:
		return Vector2.RIGHT + Vector2.DOWN
		
	elif sign(input.x) == -1 and sign(input.y) == 1:
		return Vector2.LEFT + Vector2.DOWN
	else:
		return input


func _calculate_joystick_movement() -> void:
	## Left direction
	var input_joy_axis_x = Input.get_joy_axis(current_device_id, JOY_AXIS_LEFT_X)
	var input_joy_axis_y = Input.get_joy_axis(current_device_id, JOY_AXIS_LEFT_Y)
	
	var input_joy_x = 0
	var input_joy_y = 0
	
	if abs(input_joy_axis_x) > deadzone:
		input_joy_x = input_joy_axis_x
	else:
		input_joy_x = 0
		
	if abs(input_joy_axis_y) > deadzone:
		input_joy_y = input_joy_axis_y
	else:
		input_joy_y = 0
		
	input_joy_direction_left = Vector2(input_joy_x, input_joy_y)
	
	## Right direction
	input_joy_axis_x = Input.get_joy_axis(current_device_id, JOY_AXIS_RIGHT_X)
	input_joy_axis_y = Input.get_joy_axis(current_device_id, JOY_AXIS_RIGHT_Y)
	
	if abs(input_joy_axis_x) > deadzone:
		input_joy_x = input_joy_axis_x
	else:
		input_joy_x = 0
		
	if abs(input_joy_axis_y) > deadzone:
		input_joy_y = input_joy_axis_y
	else:
		input_joy_y = 0

	input_joy_direction_right = Vector2(input_joy_x, input_joy_y)


func _update_previous_directions():
	previous_input_direction = input_direction
	previous_world_coordinate_space_direction = world_coordinate_space_direction
	
	previous_input_joy_direction_left = input_joy_direction_left
	previous_input_joy_direction_right = input_joy_direction_right
	
	previous_input_direction_deadzone_square_shape = input_direction_deadzone_square_shape
		
	previous_input_direction_horizontal_axis = input_direction_horizontal_axis
	previous_input_direction_vertical_axis = input_direction_vertical_axis
	previous_input_axis_as_vector = input_axis_as_vector
	
	previous_input_right_motion_horizontal_axis = input_right_motion_horizontal_axis
	previous_input_right_motion_vertical_axis = input_right_motion_vertical_axis
	previous_input_right_motion_axis_as_vector = input_right_motion_as_vector
	previous_input_right_motion_as_vector = Input.get_vector(left_motion_action, right_motion_action, up_motion_action, down_motion_action)

	previous_input_direction_horizontal_axis_applied_deadzone = input_direction_horizontal_axis_applied_deadzone
	previous_input_direction_vertical_axis_applied_deadzone = input_direction_vertical_axis_applied_deadzone


#region Action setters
func change_move_right_action(new_action: StringName) -> MotionInput:
	if InputMap.has_action(new_action):
		move_right_action = new_action
	else:
		push_error("MotionInput: The new move right action %s does not exist in the InputMap, create the action and then reassign it again" % new_action)
	
	return self


func change_move_left_action(new_action: StringName) -> MotionInput:
	if InputMap.has_action(new_action):
		move_left_action = new_action
	else:
		push_error("MotionInput: The new move left action %s does not exist in the InputMap, create the action and then reassign it again" % new_action)
	
	return self


func change_move_forward_action(new_action: StringName) -> MotionInput:
	if InputMap.has_action(new_action):
		move_forward_action = new_action
	else:
		push_error("MotionInput: The new move forward action %s does not exist in the InputMap, create the action and then reassign it again" % new_action)
	
	return self


func change_move_back_action(new_action: StringName) -> MotionInput:
	if InputMap.has_action(new_action):
		move_back_action = new_action
	else:
		push_error("MotionInput: The new move back action %s does not exist in the InputMap, create the action and then reassign it again" % new_action)
	
	return self
	
func change_motion_right_action(new_action: StringName) -> MotionInput:
	if InputMap.has_action(new_action):
		right_motion_action = new_action
	else:
		push_error("MotionInput: The new motion right action %s does not exist in the InputMap, create the action and then reassign it again" % new_action)
	
	return self


func change_motion_left_action(new_action: StringName) -> MotionInput:
	if InputMap.has_action(new_action):
		left_motion_action = new_action
	else:
		push_error("MotionInput: The new motion left action %s does not exist in the InputMap, create the action and then reassign it again" % new_action)
	
	return self


func change_motion_up_action(new_action: StringName) -> MotionInput:
	if InputMap.has_action(new_action):
		up_motion_action = new_action
	else:
		push_error("MotionInput: The new motion up action %s does not exist in the InputMap, create the action and then reassign it again" % new_action)
	
	return self


func change_motion_down_action(new_action: StringName) -> MotionInput:
	if InputMap.has_action(new_action):
		down_motion_action = new_action
	else:
		push_error("MotionInput: The new motion down action %s does not exist in the InputMap, create the action and then reassign it again" % new_action)
	
	return self
#endregion


func on_joy_connection_changed(device_id: int, _connected: bool):
	current_device_id = device_id
