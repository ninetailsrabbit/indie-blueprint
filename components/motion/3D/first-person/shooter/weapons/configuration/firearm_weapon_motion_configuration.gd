class_name FireArmWeaponMotionConfiguration extends Resource

@export var can_aim: bool = true
@export var sway_enabled: bool = true
@export var tilt_enabled: bool = true
@export var bob_enabled: bool = true
@export var impulse_enabled: bool = true
@export var recoil_enabled: bool = true
@export var camera_recoil_enabled: bool = true
@export var camera_shake_enabled: bool = true
@export_group("Aim")
@export var aim_input_action: StringName = InputControls.Aim
@export var keep_pressed_to_aim: bool = true
@export var center_weapon_on_aim: bool = true
@export_group("Camera shake")
@export var camera_shake_magnitude: float = 0.01
@export var camera_shake_time: float = 0.1
@export_group("Camera recoil")
@export var camera_recoil_amount: Vector3 = Vector3.ZERO
@export var camera_recoil_lerp_speed: float = 8.0
@export var camera_recoil_snap_amount: float = 6.0
@export_range(0, 179, 0.1) var zoom_level_on_aim: float = 65
## The offset to adjust the position of the weapon when aiming
@export var aim_offset: Vector3 = Vector3.ZERO
@export var aim_smoothing: float = 8.0
@export_group("Sway")
@export var sway_base_multiplier: float = 0.2
@export var sway_aim_multiplier: float = 0.2
@export var sway_canted_multiplier: float = 0.2
@export var sway_smoothing: float = 5.0
@export_group("Tilt")
@export var tilt_horizontal = 0.1
@export var tilt_vertical = 0.01
@export var tilt_smoothing = 5.0
@export var tilt_push_smoothing = 1.0
@export var tilt_hip_push_forward: float = 0.02
@export var tilt_hip_push_backward: float = 0.01
@export var tilt_inverted: bool = false
@export_group("Bob")
@export var bob_noise: FastNoiseLite
@export var bob_intensity: float = 0.05
@export var bob_frequency: float = 1.0
@export var bob_amplitude: float = 0.04
@export_group("Impulse")
@export var impulse_jump_kick: float = 0.02
@export var impulse_jump_kick_power: float = 20.0
@export var impulse_jump_rotation: Vector2 = Vector2(0.1, 0.02)
@export var impulse_jump_rotation_power: float = 5.0
@export var impulse_multiplier_on_jump: float = 1.0
@export var impulse_multiplier_on_jump_after_run: float = 1.5
@export var impulse_multiplier_on_land: float = 1.0
@export var impulse_multiplier_on_land_after_run: float = 1.5
@export var impulse_multiplier_on_crouch: float = 0.5
@export_group("Recoil")
@export var recoil_kick = 0.06
@export var recoil_kick_power = 20.0
@export var recoil_kick_recovery = 20.0
@export var recoil_vertical = 0.04
@export var recoil_horizontal = 0.01
@export var recoil_rotation_power = 20.0
@export var recoil_rotation_recovery = 20.0
