class_name FirstPersonSlideState extends FirstPersonGroundState

enum SlideSide {
	Right,
	Left,
	RandomSide, ## Always get a right or left side
	Random ## A no side can be randomized here
}

@export var slide_time: float = 1.2
@export var slide_lerp_speed: float = 8.0
## The angle in degrees you want to apply on slide motion
@export_range(0, 360.0, 1.0, "degrees") var slide_tilt := 5.0
@export var slide_tilt_comeback_time: float = 0.35
@export var slide_tilt_side: SlideSide = SlideSide.RandomSide
## This applies a momentum on the last part of the slide to continue the movement
@export var friction_momentum: float = 0.1
@export var slide_velocity_boost: float = 1.0
@export var reduce_speed_gradually: bool = true
@export var swing_head: bool = true

var slide_timer: Timer
var entry_velocity: Vector3 = Vector3.ZERO
var decrease_rate: float = 0.0
var original_camera_rotation = 0.0
var slide_side: int = 0

func ready():
	_create_slide_timer()
	

func enter():
	if is_instance_valid(slide_timer):
		slide_timer.start()
	
	entry_velocity = actor.velocity * slide_velocity_boost
	original_camera_rotation = actor.camera_controller.camera.rotation
	decrease_rate = slide_time

	match slide_tilt_side:
		SlideSide.Left:
			slide_side = 1
		SlideSide.Right:
			slide_side = -1
		SlideSide.RandomSide:
			slide_side = [-1, 1].pick_random()
		SlideSide.Random:
			slide_side = sign(randi_range(-1, 1))
			
	crouch_animation()


func exit(next_state: IndieBlueprintMachineState) -> void:
	slide_timer.stop()
	decrease_rate = slide_time
	
	if actor.camera_controller.camera.rotation.z != original_camera_rotation.z:
		var tween = create_tween()
		tween.tween_property(actor.camera_controller.camera, "rotation:z", original_camera_rotation.z, slide_tilt_comeback_time)\
			.set_ease(Tween.EASE_OUT)
	
	if not next_state is FirstPersonCrouchState:
		crouch_exit_animation()


func physics_update(delta):
	super.physics_update(delta)
	
	if reduce_speed_gradually:
		decrease_rate -= delta
		
	var momentum = decrease_rate + friction_momentum
	
	actor.velocity = Vector3(entry_velocity.x * momentum, actor.velocity.y, entry_velocity.z * momentum)
	
	if swing_head and slide_tilt > 0:
		actor.camera_controller.camera.rotation.z =  lerp_angle(actor.camera_controller.camera.rotation.z, slide_side * deg_to_rad(slide_tilt), delta * slide_lerp_speed)
   
	if not actor.ceil_shape_cast.is_colliding():
		detect_jump()
		
	actor.move_and_slide()
	
	
func _create_slide_timer() -> void:
	slide_timer = IndieBlueprintTimeHelper.create_physics_timer(slide_time, false, true)
	slide_timer.name = "SlideTimer"
	
	add_child(slide_timer)
	slide_timer.timeout.connect(on_slider_timeout)


func on_slider_timeout():
	detect_crouch()
	
	if actor.crouch and actor.ceil_shape_cast.is_colliding():
		FSM.change_state_to(FirstPersonCrouchState)
	else:
		FSM.change_state_to(FirstPersonWalkState)
