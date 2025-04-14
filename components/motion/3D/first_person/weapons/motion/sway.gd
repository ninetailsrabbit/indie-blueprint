class_name WeaponSway extends WeaponMotion

@export var base_multiplier: float = 0.2
@export var aim_multiplier: float = 0.2
@export var canted_multiplier: float = 0.2
@export var smoothing: float = 5.0

var original_rotation: Vector3 = Vector3.ZERO
var target_rotation: Vector3 = Vector3.ZERO
var relative_input: Vector2 = Vector2.ZERO

var motion_input: MotionInput = MotionInput.new(self)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and IndieBlueprintInputHelper.is_mouse_captured():
		var motion: InputEventMouseMotion = event.xformed_by(get_tree().root.get_final_transform())
		relative_input = motion.relative


func _ready():
	original_rotation = rotation_degrees


func _physics_process(delta: float) -> void:
	var joystick_motion: Vector2 = motion_input.input_right_motion_as_vector
	## Support for right joystick, if no gamepad is connected this value is not changed
	if joystick_motion.length() >= 0.2:
		relative_input = joystick_motion
		#var controller_sensitivity: float = controller_joystick_sensitivity / 100 # 5 becomes 0.05
		#var twist_input: float = -joystick_motion.x * controller_sensitivity ## Giro
		#var pitch_input: float = -joystick_motion.y * controller_sensitivity ## Cabeceo
		#
	
	target_rotation = Vector3(
	original_rotation.x + relative_input.y * base_multiplier * clampf(1.0, 0.1, 1.0), 
	original_rotation.y + - relative_input.x * base_multiplier * clampf(1.0, 0.1, 1.0), 
	original_rotation.z)

	rotation_degrees = rotation_degrees.lerp(target_rotation, delta * smoothing)
	relative_input = Vector2.ZERO
