class_name FirstPersonWallState extends IndieBlueprintMachineState

@export var actor: IndieBlueprintFirstPersonController
@export_group("Parameters")
@export var gravity_force: float = 9.8
@export var jump_input_action: StringName = InputControls.JumpAction

var current_gravity_force: float = gravity_force


func physics_update(delta: float):
	apply_gravity(current_gravity_force, delta)


func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	actor.velocity += IndieBlueprintVectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta


func detect_wall_jump() -> void:
	var wall_normal: Vector3 = actor.wall_normal()
	
	if actor.wall_jump \
		and not wall_normal.is_zero_approx() \
		and InputMap.has_action(jump_input_action) \
		and Input.is_action_just_pressed(jump_input_action):
		
		FSM.change_state_to(FirstPersonWallJumpState, {"wall_normal": wall_normal})


func detect_fall(last_jumped_position: Vector3) -> void:
	var up_direction_opposite: Vector3 = IndieBlueprintVectorHelper.up_direction_opposite_vector3(actor.up_direction)
		
	if up_direction_opposite.is_equal_approx(Vector3.DOWN) and actor.position.y < last_jumped_position.y \
	or  up_direction_opposite.is_equal_approx(Vector3.UP) and actor.position.y > last_jumped_position.y \
	or up_direction_opposite.is_equal_approx(Vector3.RIGHT) and actor.position.x > last_jumped_position.x \
	or up_direction_opposite.is_equal_approx(Vector3.LEFT) and actor.position.x < last_jumped_position.x:
		FSM.change_state_to(FirstPersonFallState)
