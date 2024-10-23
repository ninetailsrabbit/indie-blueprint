class_name SpecialState extends MachineState

@export var actor: FirstPersonController
@export_group("Parameters")
@export var gravity_force: float = 9.8
@export var speed: float = 3.0
@export var side_speed: float = 2.5
@export var acceleration: float = 8.0
@export var friction: float = 10.0
@export_group("Input actions")
@export var run_input_action: String = "run"
@export var jump_input_action: String = "jump"


func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	actor.velocity += VectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta


func detect_jump() -> void:
	if actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		FSM.change_state_to("Jump")


func get_speed() -> float:
	return side_speed if actor.motion_input.input_direction in VectorHelper.horizontal_directions_v2 else speed
