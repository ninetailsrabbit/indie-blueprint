class_name WeaponRecoil extends FireArmWeaponMotion

@export var kick: float = 0.06
@export var kick_power: float = 20.0
@export var kick_recovery: float = 20.0
@export var vertical_recoil: float = 0.04
@export var horizontal_recoil: float = 0.01
@export var rotation_power: float = 20.0
@export var rotation_recovery: float = 20.0


var current_kick: Vector3 = Vector3.ZERO
var current_rotation: Vector3 = Vector3.ZERO


func _physics_process(delta: float) -> void:
	calculate_recoil(delta)


func calculate_recoil(delta):
	current_rotation = lerp(current_rotation, Vector3.ZERO, delta * rotation_recovery)
	rotation = lerp(rotation, current_rotation, delta * rotation_power)

	current_kick = lerp(current_kick, Vector3.ZERO, delta * kick_recovery)
	position = lerp(position, current_kick, delta * kick_power)


func apply_recoil():
	if is_enabled():
		current_rotation = Vector3(-vertical_recoil, randf_range(-horizontal_recoil, horizontal_recoil), 0.0)
		current_kick = Vector3(0.0, 0.0, - kick)
