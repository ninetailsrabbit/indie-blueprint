class_name WeaponSway extends FireArmWeaponMotion

@export var base_multiplier: float = 0.2
@export var aim_multiplier: float = 0.2
@export var canted_multiplier: float = 0.2
@export var smoothing: float = 5.0

var original_rotation: Vector3 = Vector3.ZERO
var target_rotation: Vector3 = Vector3.ZERO
var relative_input: Vector2 = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and InputHelper.is_mouse_captured():
		var motion: InputEventMouseMotion = event.xformed_by(get_tree().root.get_final_transform())
		relative_input = motion.relative


func _ready():
	original_rotation = rotation_degrees


func _physics_process(delta: float) -> void:
	target_rotation = Vector3(
	original_rotation.x + relative_input.y * base_multiplier * clampf(1.0, 0.1, 1.0), 
	original_rotation.y + - relative_input.x * base_multiplier * clampf(1.0, 0.1, 1.0), 
	original_rotation.z)

	rotation_degrees = rotation_degrees.lerp(target_rotation, delta * smoothing)
	relative_input = Vector2.ZERO
