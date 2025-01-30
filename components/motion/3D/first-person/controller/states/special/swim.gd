class_name Swim extends SpecialState


@export var speed_reduction_on_water_entrance: float = 2.0
@export var eyes: Node3D
@export var safe_submerged_margin: float = 0.15
@export var underwater_exit_impulse: float = 0.05
@export var can_jump_when_not_submerged: bool = true

##the height at which water is in the global world Y axis to detect if it's submerged or not
var water_height: float = 0.0
var was_underwater: bool = false
var is_underwater: bool = false:
	set(value):
		if value != is_underwater:
			is_underwater = value
			actor.is_underwater = is_underwater
var water_manager: WaterManager


func handle_input(_event: InputEvent) -> void:
	detect_ladder_input()


func ready() -> void:
	water_manager = get_tree().get_first_node_in_group(WaterManager.GroupName)


func enter():
	actor.velocity /= speed_reduction_on_water_entrance
	actor.move_and_slide()


func exit(_next_state: MachineState):
	is_underwater = false
	

func physics_update(delta: float):
	was_underwater = is_underwater
	var depth = water_manager.calculate_water_height(actor.global_position) - (eyes.global_position.y - safe_submerged_margin)
	is_underwater = depth > 0

	if actor.motion_input.input_direction.is_zero_approx():
		decelerate(delta)
	else:
		accelerate(delta)
		
	if is_underwater:
		apply_gravity(gravity_force, delta)
	else:
		if can_jump_when_not_submerged:
			detect_jump()
		
	if was_underwater and not is_underwater:
		actor.velocity *= actor.up_direction * underwater_exit_impulse
		
	if actor.global_position.y > water_height or (not is_underwater and actor.is_on_floor()):
		FSM.change_state_to(Fall)
		return
		
	detect_ladder()
		
	actor.move_and_slide()
	

func accelerate(delta: float = get_physics_process_delta_time()):
	var direction = actor.motion_input.world_coordinate_space_direction
	var camera_direction = Camera3DHelper.forward_direction(actor.camera)
	var current_speed = get_speed()

	if is_underwater:
		if actor.motion_input.input_direction.is_equal_approx(Vector2.UP):
			direction = camera_direction
			
		elif actor.motion_input.input_direction.is_equal_approx(Vector2.DOWN):
			direction = -camera_direction
	else:
		# Means that it's looking down so can submerge into the water
		if sign(camera_direction.y) == sign(VectorHelper.up_direction_opposite_vector3(actor.up_direction)).y:
			direction = camera_direction
			
	if acceleration > 0:
		actor.velocity = lerp(actor.velocity, direction * current_speed, clamp(acceleration * delta, 0, 1.0))
	else:
		actor.velocity = direction * current_speed
			

func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	## With this line we make sure the swim impulse is canceled and start to apply the gravity force in the water
	if is_underwater and actor.velocity.y > 0:
		actor.velocity.y = (VectorHelper.up_direction_opposite_vector3(actor.up_direction) * gravity_force).y
		
	if friction > 0:
		actor.velocity = lerp(actor.velocity, Vector3(0, actor.velocity.y if is_underwater else 0.0, 0), clamp(friction * delta, 0, 1.0))
	else:
		actor.velocity = Vector3(0, actor.velocity.y if is_underwater else 0.0, 0)


func on_water_level_changed(new_water_level: float) -> void:
	water_height = new_water_level
