class_name WallRun extends AirState

@export_category("Camera")
@export_range(0, 360.0, 0.01) var camera_tilt_angle: float = 5.0
@export_range(0, 360.0, 0.01) var camera_lerp_tilt_factor: float = 8.0
@export var camera_tilt_comeback_time: float = 0.35
@export_category("Parameters")
@export var wall_speed: float = 5.0
@export var reduce_speed_gradually: bool = true
## The friction rate to reduce speed gradually on each frame multiplied by delta
@export var friction_to_reduce_speed: float = 0.1
## Reduce the velocity of the run based on this friction coeficient
@export var wall_friction: float = 0.2
## Set to zero to not have a limited time on wall running. 
## It can be further interrupted by the termination of the wall itself or by an external force that interrupts the action.
@export var wall_run_time: float = 0.7
## When the wall run ends, the player cannot wall run again until this time passed
@export var wall_run_cooldown: float = 1.0

var current_wall_direction: Vector3 = Vector3.ZERO
var current_wall_normal: Vector3 = Vector3.ZERO
var wall_run_timer: Timer
var wall_run_cooldown_timer: Timer
var decrease_rate: float = 0.0

var original_camera_rotation: Vector3 = Vector3.ZERO


func ready() -> void:
	_create_wall_run_timers()


func enter() -> void:
	original_camera_rotation = actor.camera.rotation
	
	current_wall_normal = actor.get_current_wall_detected_normal()
	current_wall_direction = calculate_wall_run_direction()
	
	if current_wall_normal.is_zero_approx() or current_wall_direction.is_zero_approx():
		FSM.change_state_to(Fall)
		return
		
	if wall_run_time > 0 and is_instance_valid(wall_run_timer):
		wall_run_timer.start(wall_run_time)
	
	if is_instance_valid(wall_run_cooldown_timer):
		wall_run_cooldown_timer.stop()


func physics_update(delta: float) -> void:
	actor.camera.rotation.z = lerp_angle(actor.camera.rotation.z, calculate_camera_angle(), delta * camera_lerp_tilt_factor)
	
	detect_wall_jump()
	
	actor.move_and_slide()


func exit(_next_state: MachineState) -> void:
	if actor.camera.rotation.z != original_camera_rotation.z:
		var tween: Tween = create_tween()
		tween.tween_property(actor.camera, "rotation:z", original_camera_rotation.z, camera_tilt_comeback_time)\
			.set_ease(Tween.EASE_OUT)
	
	wall_run_timer.stop()
	

func calculate_camera_angle() -> float:
	var angle: float = deg_to_rad(camera_tilt_angle)
	
	if current_wall_normal.is_equal_approx(Vector3.RIGHT) or current_wall_normal.is_equal_approx(Vector3.FORWARD):
		angle *= -1
		
	return angle


func calculate_wall_run_direction() -> Vector3:
	var wall_direction = current_wall_normal.cross(Vector3.UP)
	var player_direction: Vector3 = actor.global_transform.basis.z
	
	if (-player_direction - wall_direction).length() > (-player_direction - -wall_direction).length():
			wall_direction *= -1
	
	return wall_direction


func _create_wall_run_timers() -> void:
	if wall_run_timer == null:
		wall_run_timer = Timer.new()
		wall_run_timer.name = "WallRunTimer"
		
	wall_run_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	wall_run_timer.wait_time = maxf(0.05, wall_run_time)
	wall_run_timer.autostart = false
	wall_run_timer.one_shot = true
	
	wall_run_timer.timeout.connect(on_wall_run_timer_timeout)
	add_child(wall_run_timer)
	
	if wall_run_cooldown_timer == null:
		wall_run_cooldown_timer = Timer.new()
		wall_run_timer.name = "WallRunCooldownTimer"
		
	wall_run_cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	wall_run_cooldown_timer.wait_time = maxf(0.05, wall_run_time)
	wall_run_cooldown_timer.autostart = false
	wall_run_cooldown_timer.one_shot = true
	
	add_child(wall_run_cooldown_timer)
		
		
func on_wall_run_timer_timeout() -> void:
	wall_run_cooldown_timer.start(wall_run_cooldown)
	FSM.change_state_to(Fall)
