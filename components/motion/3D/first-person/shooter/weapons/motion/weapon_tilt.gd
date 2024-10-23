class_name WeaponTilt extends FireArmWeaponMotion

@export var tilt_horizontal: float = 0.1
@export var tilt_vertical: float = 0.01
@export var tilt_smoothing: float = 5.0
@export var hip_push_forward: float = 0.02
@export var hip_push_backward: float = 0.01
@export var push_smoothing: float = 1.0
@export var inverted: bool = true


var target_tilt_rotation = Vector3.ZERO
var target_push_position = Vector3.ZERO
var motion_input: TransformedInput = TransformedInput.new(self)


func _physics_process(delta):
	motion_input.update()

	if motion_input.input_direction.y < 0:
		target_push_position.z = hip_push_forward * motion_input.input_direction.y
	else:
		target_push_position.z = hip_push_backward * motion_input.input_direction.y

	target_tilt_rotation.z = tilt_horizontal * motion_input.input_direction.x
	target_tilt_rotation.x = tilt_vertical * -motion_input.input_direction.y
	
	if inverted:
		target_tilt_rotation.z *= -1
		target_tilt_rotation.x *= -1

	position.z = lerp(position.z, target_push_position.z, delta * push_smoothing)
	rotation.x = lerp_angle(rotation.x, target_tilt_rotation.x, delta * tilt_smoothing)
	rotation.z = lerp_angle(rotation.z, target_tilt_rotation.z, delta * tilt_smoothing)
