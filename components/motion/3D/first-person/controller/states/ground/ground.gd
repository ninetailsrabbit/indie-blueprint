class_name GroundState extends MachineState

@export var actor: FirstPersonController
@export_group("Parameters")
@export var gravity_force: float = 9.8
@export var speed: float = 3.0
@export var side_speed: float = 2.5
@export var acceleration: float = 8.0
@export var friction: float = 10.0
@export_group("Stair stepping")
## Define if the behaviour to step & down stairs it's enabled
@export var stair_stepping_enabled := true
## Maximum height in meters the player can step up.
@export var max_step_up := 0.6 
## Maximum height in meters the player can step down.
@export var max_step_down := -0.6
## Shortcut for converting vectors to vertical
@export var vertical := Vector3(0, 1, 0)
## Shortcut for converting vectors to horizontal
@export var horizontal := Vector3(1, 0, 1)
@export_group("Input actions")
@export var run_input_action: StringName = InputControls.RunAction
@export var jump_input_action: StringName = InputControls.JumpAction
@export var crouch_input_action: StringName = InputControls.CrouchAction
@export var crawl_input_action: StringName = InputControls.CrawlAction
@export_group("Animation")
@export var crouch_animation: StringName = "crouch"
@export var crawl_animation: StringName = "crawl"

var current_speed: float = 0
var stair_stepping := false


func physics_update(delta):
	if not actor.is_grounded:
		apply_gravity(gravity_force, delta)

	if actor.is_falling() and not stair_stepping:
		FSM.change_state_to("Fall")


func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	actor.velocity += VectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta


func accelerate(delta: float = get_physics_process_delta_time()) -> void:
	var direction = actor.motion_input.world_coordinate_space_direction
	current_speed = get_speed()
	
	if acceleration > 0:
		actor.velocity = lerp(actor.velocity, direction * current_speed, clamp(acceleration * delta, 0, 1.0))
	else:
		actor.velocity = direction * current_speed


func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	if friction > 0:
		actor.velocity = lerp(actor.velocity, Vector3.ZERO, clamp(friction * delta, 0, 1.0))
	else:
		actor.velocity = Vector3.ZERO


func get_speed() -> float:
	return side_speed if actor.motion_input.world_coordinate_space_direction in VectorHelper.horizontal_directions_v2 else speed


func stair_step_up():
	if not actor.stairs or not stair_stepping_enabled:
		return
		
	stair_stepping = false
	
	if actor.motion_input.world_coordinate_space_direction.is_zero_approx():
		return
	
	var body_test_params := PhysicsTestMotionParameters3D.new()
	var body_test_result := PhysicsTestMotionResult3D.new()
	var test_transform = actor.global_transform ## Storing current global_transform for testing
	var distance = actor.motion_input.world_coordinate_space_direction * 0.1 ## Distance forward we want to check
	
	body_test_params.from =  actor.global_transform ## Self as origin point
	body_test_params.motion = distance ## Go forward by current distance

	# Pre-check: Are we colliding?
	if not PhysicsServer3D.body_test_motion(actor.get_rid(), body_test_params, body_test_result):
		return
	
	## 1- Move test transform to collision location
	var remainder = body_test_result.get_remainder() ## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel()) ## Move test_transform by distance traveled before collision

	## 2. Move test_transform up to ceiling (if any)
	var step_up = max_step_up * vertical
	
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	
	PhysicsServer3D.body_test_motion(actor.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	## 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(actor.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())


	## 3.5 Project remaining along wall normal (if any). So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = actor.motion_input.world_coordinate_space_direction.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (actor.motion_input.world_coordinate_space_direction - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(actor.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

	## 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = max_step_up * -vertical
	
	## Return if no collision
	if not PhysicsServer3D.body_test_motion(actor.get_rid(), body_test_params, body_test_result):
		return
	
	test_transform = test_transform.translated(body_test_result.get_travel())
	
	## 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()
	var temp_floor_max_angle = actor.floor_max_angle + deg_to_rad(20)
	
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > temp_floor_max_angle):
		return
	
	stair_stepping = true
	# 6. Move player up
	var global_pos = actor.global_position
	#var step_up_dist = test_transform.origin.y - global_pos.y

	global_pos.y = test_transform.origin.y
	actor.global_position = global_pos

	
func stair_step_down():
	if not actor.stairs or not stair_stepping_enabled:
		return
		
	stair_stepping = false
	
	if actor.velocity.y <= 0 and actor.was_grounded:
		## Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = actor.global_transform ## We get the player's current global_transform
		body_test_params.motion = Vector3(0, max_step_down, 0) ## We project the player downward

		if PhysicsServer3D.body_test_motion(actor.get_rid(), body_test_params, body_test_result):
			stair_stepping = true
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			actor.position.y += body_test_result.get_travel().y
			actor.apply_floor_snap()
			actor.is_grounded = true


#region State Detectors
func detect_run() -> void:
	if actor.run and InputMap.has_action(run_input_action) and Input.is_action_pressed(run_input_action):
		FSM.change_state_to("Run")


func detect_slide() -> void:
	if actor.crouch and actor.slide and InputMap.has_action(crouch_input_action) and Input.is_action_pressed(crouch_input_action):
		FSM.change_state_to("Slide")
	

func detect_crouch() -> void:
	if actor.crouch and InputMap.has_action(crouch_input_action) and Input.is_action_pressed(crouch_input_action):
		FSM.change_state_to("Crouch")


func detect_crawl() -> void:
	if actor.crawl and InputMap.has_action(crawl_input_action) and Input.is_action_pressed(crawl_input_action):
		FSM.change_state_to("Crawl")


func detect_jump() -> void:
	if actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		FSM.change_state_to("Jump")
#endregion
