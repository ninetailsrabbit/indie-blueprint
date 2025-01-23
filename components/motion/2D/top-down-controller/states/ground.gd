class_name TopDownGround extends MachineState


@export var actor: TopDownController
@export var speed: float = 300.0
@export var acceleration: float = 25.0
@export var friction: float = 50.0
@export var dash_input_action: StringName = InputControls.DashAction


func _ready() -> void:
	if actor == null:
		actor = get_tree().get_first_node_in_group(TopDownController.GroupName)


func move(delta: float) -> void:
	if actor.motion_input.input_axis_as_vector.is_zero_approx():
		decelerate(delta)
	else:
		accelerate(delta)
		
	actor.move_and_slide()

#
func accelerate(delta: float = get_physics_process_delta_time()) -> void:
	if acceleration > 0:
		actor.velocity = actor.velocity.lerp(actor.motion_input.input_axis_as_vector.normalized() * speed, acceleration * delta)
	else:
		actor.velocity =  actor.motion_input.input_axis_as_vector.normalized() * speed


func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	if friction > 0:
		actor.velocity = actor.velocity.lerp(Vector2.ZERO, friction * delta)
	else:
		actor.velocity = Vector2.ZERO
		
		
func detect_dash() -> void:
	if InputMap.has_action(dash_input_action) and Input.is_action_just_pressed(dash_input_action):
		FSM.change_state_to(TopDownDash)
