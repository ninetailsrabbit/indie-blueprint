class_name WallJump extends AirState

@export var wall_jump_horizontal_force: float = 5.0
@export var wall_jump_vertical_force: float = 7.0
@export var wall_jump_times: int = 3


var current_wall_jump_times: int = 0
var current_wall_normal: Vector3 = Vector3.ZERO


func enter() -> void:
	apply_wall_jump()


func exit(_next_state: MachineState):
	current_wall_jump_times = 0
	current_wall_normal = Vector3.ZERO
	

func physics_update(delta: float):
	super.physics_update(delta)
	
	if actor.is_grounded:
		if actor.motion_input.input_direction.is_zero_approx():
			FSM.change_state_to(Idle)
		else:
			FSM.change_state_to(Walk)
			
	if actor.can_wall_jump() and current_wall_jump_times < wall_jump_times and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		apply_wall_jump()
		
	actor.move_and_slide()
	

func apply_wall_jump() -> void:
	current_wall_normal = get_current_wall_normal()
		
	if current_wall_normal.is_zero_approx():
		FSM.change_state_to(Fall)
		return
	
	current_wall_jump_times += 1
	actor.velocity = wall_jump_horizontal_force * current_wall_normal
	actor.velocity.y = wall_jump_vertical_force


func get_current_wall_normal() -> Vector3:
	if actor.top_left_wall_checker.is_colliding():
		return actor.top_left_wall_checker.get_collision_normal()
	elif actor.bottom_left_wall_checker.is_colliding():
		return actor.bottom_left_wall_checker.get_collision_normal()
	elif actor.top_right_wall_checker.is_colliding():
		return actor.top_right_wall_checker.get_collision_normal()
	elif actor.bottom_right_wall_checker.is_colliding():
		return actor.bottom_right_wall_checker_wall_checker.get_collision_normal()
	else:
		return Vector3.ZERO
