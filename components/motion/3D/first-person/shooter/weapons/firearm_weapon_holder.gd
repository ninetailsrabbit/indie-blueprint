@icon("res://components/motion/3D/first-person/shooter/weapons/weapon_holder.svg")
class_name FireArmWeaponHolder extends Node3D

signal dropped_weapon(weapon: FireArmWeaponMesh)
signal changed_weapon(from: WeaponDatabase.WeaponRecord, to: WeaponDatabase.WeaponRecord)
signal stored_weapon(weapon: WeaponDatabase.WeaponRecord)
signal drawed_weapon(weapon: WeaponDatabase.WeaponRecord)

@export var actor: FirstPersonController
@export var camera_controller: CameraController3D
## This is a node that holds a Camera3D and where the weapon recoil will be applied to simulate the kick on each shoot that affects accuracy. 
@export var camera_recoil_node: Node3D
## Slots to hold weapons on the format Dictionary[InputAction, WeaponId] where input action is the key that
## equips the related weapon with the id provided
@export var slots: Dictionary = {
	InputControls.PrimaryWeapon: "",
	InputControls.SecondaryWeapon: "",
	InputControls.HeavyWeapon: "",
	InputControls.MeleeWeapon: "",
}
## This positions represents where the holder position needs to be to show the selected weapon
@export var weapon_positions: Dictionary = {
	## Example, this is the weapon position to move when equipped, always keep FireArmWeaponHolder node on Vector3.Zero
	#WeaponDatabase.IdentifierRifleAr15: Vector3(0.23, -0.215, -0.5),
}

## This nodes needs to be nested in the scene tree on the same order as listed here
## Sway > Noise > Tilt > > Impulse > Recoil -> FireArmWeapon
@onready var weapon_sway: WeaponSway = $Sway
@onready var weapon_noise: WeaponBob = $Sway/Noise
@onready var weapon_tilt: WeaponTilt = $Sway/Noise/Tilt
@onready var weapon_impulse: WeaponImpulse = $Sway/Noise/Tilt/Impulse
@onready var weapon_recoil: WeaponRecoil = $Sway/Noise/Tilt/Impulse/Recoil
@onready var firearm_weapon_placement: FireArmWeapon = $Sway/Noise/Tilt/Impulse/Recoil/FireArmWeapon

enum WeaponHolderStates {
	Draw,
	Store,
	Neutral,
	Dismantle
}

var camera_recoil_target_rotation: Vector3
var camera_current_recoil_rotation: Vector3

var original_holder_position: Vector3
var original_camera_fov: float

var current_state: WeaponHolderStates = WeaponHolderStates.Neutral:
	set(value):
		if value != current_state:
			current_state = value
			set_physics_process(current_state == WeaponHolderStates.Neutral)
			set_process_unhandled_input(current_state in [WeaponHolderStates.Neutral, WeaponHolderStates.Dismantle])
	
var current_weapon: WeaponDatabase.WeaponRecord:
	set(value):
		if value != current_weapon:
			current_weapon = value
			
			if current_weapon == null:
				current_state = WeaponHolderStates.Dismantle
			else:
				current_state = WeaponHolderStates.Neutral
				


func _unhandled_input(_event: InputEvent) -> void:
	if current_state == WeaponHolderStates.Neutral:
		for input_action: String in slots.keys():
			if WeaponDatabase.exists(slots[input_action]) and InputHelper.action_just_pressed_and_exists(input_action):
				change_weapon_to(slots[input_action])
				break
		

func _ready() -> void:
	_prepare_firearm_weapon_placement(firearm_weapon_placement)
	
	original_holder_position = position
	original_camera_fov = camera_controller.camera.fov
	

func _physics_process(delta: float) -> void:
	if current_weapon:
		apply_camera_recoil(delta)
		check_aim()
		

func apply_camera_recoil(delta: float) -> void:
	if _camera_recoil_can_be_applied():
		## Head recoil to affect on accuracy moving the current camera 3d
		camera_recoil_target_rotation = lerp(camera_recoil_target_rotation, Vector3.ZERO, firearm_weapon_placement.weapon_configuration.motion.camera_recoil_lerp_speed * delta)
		camera_current_recoil_rotation = lerp(camera_current_recoil_rotation, camera_recoil_target_rotation, firearm_weapon_placement.weapon_configuration.motion.camera_recoil_snap_amount * delta)
		camera_recoil_node.basis = Quaternion.from_euler(camera_current_recoil_rotation)
		

func add_camera_recoil() -> void:
	if _camera_recoil_can_be_applied():
		var recoil_amount: Vector3 = firearm_weapon_placement.weapon_configuration.motion.camera_recoil_amount
		
		camera_recoil_target_rotation += Vector3(
			recoil_amount.x, 
			randf_range(-recoil_amount.y, recoil_amount.y),
			randf_range(-recoil_amount.z, recoil_amount.z),
		)


func check_aim(delta: float = get_physics_process_delta_time()) -> void:
	if _can_aim():
		match firearm_weapon_placement.current_aim_state:
			FireArmWeapon.AimStates.Aim:
				if firearm_weapon_placement.weapon_configuration.motion.center_weapon_on_aim:
					position = position.lerp(Vector3(0, position.y, position.z), firearm_weapon_placement.weapon_configuration.motion.aim_smoothing * delta)
				
				rotation = Vector3.ZERO
				camera_controller.camera.fov = lerpf(camera_controller.camera.fov, firearm_weapon_placement.weapon_configuration.motion.zoom_level_on_aim, firearm_weapon_placement.weapon_configuration.motion.aim_smoothing * delta)
			
			FireArmWeapon.AimStates.Holded:
				camera_controller.camera.fov = lerpf(camera_controller.camera.fov, original_camera_fov, firearm_weapon_placement.weapon_configuration.motion.aim_smoothing * delta)
				
				if firearm_weapon_placement.weapon_configuration.motion.center_weapon_on_aim:
					position = position.lerp(original_holder_position, firearm_weapon_placement.weapon_configuration.motion.aim_smoothing * delta)
	

## 1 - Store the current equipped weapon if it exists
## 2 - Run the store animation, after finish, hide and disable the process of that node
## 3 - Assign the new weapon mesh and configuration to the firearm holder
## 4 - Add the mesh as a child of the firearm holder if it was not
## 5 - Run the draw animation to show the new weapon
func change_weapon_to(id: StringName) -> void:
	if current_weapon and current_weapon.id == id:
		return
	
	var previous_weapon = current_weapon
	var new_weapon: WeaponDatabase.WeaponRecord = WeaponDatabase.get_weapon(id)
	
	if previous_weapon != null:
		await unequip_current_weapon()

	await equip_new_weapon(new_weapon)
	
	if previous_weapon and new_weapon:
		changed_weapon.emit(previous_weapon, new_weapon)


func equip_new_weapon(new_weapon: WeaponDatabase.WeaponRecord) -> void:
	firearm_weapon_placement.weapon_mesh = new_weapon.mesh
	firearm_weapon_placement.weapon_configuration = new_weapon.configuration
	
	current_weapon = new_weapon
	current_state = WeaponHolderStates.Draw
	
	_prepare_weapon_motion(new_weapon.configuration)
		
	if not firearm_weapon_placement.weapon_mesh.is_inside_tree():
		firearm_weapon_placement.add_child(firearm_weapon_placement.weapon_mesh)
	
	firearm_weapon_placement.weapon_mesh.show()
	firearm_weapon_placement.weapon_mesh.process_mode = Node.PROCESS_MODE_INHERIT
	
	position = weapon_positions[current_weapon.id]
	original_holder_position = position
	
	await firearm_weapon_placement.weapon_mesh.draw_animation()
	current_state = WeaponHolderStates.Neutral
	
	drawed_weapon.emit(current_weapon)


func unequip_current_weapon() -> void:
	if firearm_weapon_placement.weapon_mesh:
		current_state = WeaponHolderStates.Store
		
		await firearm_weapon_placement.weapon_mesh.store_animation()
		firearm_weapon_placement.weapon_mesh.hide()
		firearm_weapon_placement.weapon_mesh.process_mode = Node.PROCESS_MODE_DISABLED
		
		position = Vector3.ZERO
		original_holder_position = position
		
		current_weapon = null
		
		stored_weapon.emit(current_weapon)
		
		
func assign_primary_weapon_slot(id: StringName) -> void:
	if WeaponDatabase.exists(id):
		slots[InputControls.PrimaryWeapon] = id


func assign_secondary_weapon_slot(id: StringName) -> void:
	if WeaponDatabase.exists(id):
		slots[InputControls.SecondaryWeapon] = id


func assign_heavy_weapon_slot(id: StringName) -> void:
	if WeaponDatabase.exists(id):
		slots[InputControls.HeavyWeapon] = id


func assign_melee_weapon_slot(id: StringName) -> void:
	if WeaponDatabase.exists(id):
		slots[InputControls.MeleeWeapon] = id


func disable_weapon_motion() -> void:
	weapon_sway.disable()
	weapon_noise.disable()
	weapon_tilt.disable()
	weapon_impulse.disable()
	weapon_recoil.disable()


func enable_weapon_motion() -> void:
	weapon_sway.enable()
	weapon_noise.enable()
	weapon_tilt.enable()
	weapon_impulse.enable()
	weapon_recoil.enable()


func _camera_recoil_can_be_applied() -> bool:
	return current_weapon and firearm_weapon_placement.weapon_configuration.motion.camera_recoil_enabled and camera_recoil_node


func _prepare_firearm_weapon_placement(weapon_placement: FireArmWeapon = firearm_weapon_placement) -> void:
	if not weapon_placement.fired.is_connected(on_fired_weapon):
		weapon_placement.fired.connect(on_fired_weapon)
		
	position = Vector3.ZERO


func _prepare_weapon_motion(weapon_configuration: FireArmWeaponConfiguration) -> void:
	if weapon_configuration.motion.sway_enabled:
		weapon_sway.base_multiplier = weapon_configuration.motion.sway_base_multiplier
		weapon_sway.aim_multiplier = weapon_configuration.motion.sway_aim_multiplier
		weapon_sway.canted_multiplier = weapon_configuration.motion.sway_canted_multiplier
		weapon_sway.smoothing = weapon_configuration.motion.sway_smoothing
	else:
		weapon_sway.disable()
		
	if weapon_configuration.motion.bob_enabled:
		weapon_noise.headbob_intensity = weapon_configuration.motion.bob_intensity
		weapon_noise.noise = weapon_configuration.motion.bob_noise
		weapon_noise.target_frequency = weapon_configuration.motion.bob_frequency
		weapon_noise.target_amplitude = weapon_configuration.motion.bob_amplitude
	else:
		weapon_noise.disable()
	
	if weapon_configuration.motion.tilt_enabled:
		weapon_tilt.tilt_horizontal = weapon_configuration.motion.tilt_horizontal
		weapon_tilt.tilt_vertical = weapon_configuration.motion.tilt_vertical
		weapon_tilt.tilt_smoothing = weapon_configuration.motion.tilt_smoothing
		weapon_tilt.push_smoothing = weapon_configuration.motion.tilt_push_smoothing
		weapon_tilt.hip_push_backward = weapon_configuration.motion.tilt_hip_push_backward
		weapon_tilt.hip_push_forward = weapon_configuration.motion.tilt_hip_push_forward
		weapon_tilt.inverted = weapon_configuration.motion.tilt_inverted
	else:
		weapon_tilt.disable()
	
	if weapon_configuration.motion.impulse_enabled:
		weapon_impulse.jump_kick = weapon_configuration.motion.impulse_jump_kick
		weapon_impulse.jump_kick_power = weapon_configuration.motion.impulse_jump_kick_power
		weapon_impulse.jump_rotation = weapon_configuration.motion.impulse_jump_rotation
		weapon_impulse.jump_rotation_power = weapon_configuration.motion.impulse_jump_rotation_power
		weapon_impulse.multiplier_on_crouch = weapon_configuration.motion.impulse_multiplier_on_crouch
		weapon_impulse.multiplier_on_jump = weapon_configuration.motion.impulse_multiplier_on_jump
		weapon_impulse.multiplier_on_jump_after_run = weapon_configuration.motion.impulse_multiplier_on_jump_after_run
		weapon_impulse.multiplier_on_land = weapon_configuration.motion.impulse_multiplier_on_land
		weapon_impulse.multiplier_on_land_after_run = weapon_configuration.motion.impulse_multiplier_on_land_after_run
	else:
		weapon_impulse.disable()
	
	if weapon_configuration.motion.recoil_enabled:
		weapon_recoil.kick = weapon_configuration.motion.recoil_kick
		weapon_recoil.kick_power = weapon_configuration.motion.recoil_kick_power
		weapon_recoil.kick_recovery = weapon_configuration.motion.recoil_kick_recovery
		weapon_recoil.rotation_power = weapon_configuration.motion.recoil_rotation_power
		weapon_recoil.rotation_recovery = weapon_configuration.motion.recoil_rotation_recovery
		weapon_recoil.horizontal_recoil = weapon_configuration.motion.recoil_horizontal
		weapon_recoil.vertical_recoil = weapon_configuration.motion.recoil_vertical
	else:
		weapon_recoil.disable()


func _can_aim() -> bool:
	return current_weapon and firearm_weapon_placement.weapon_configuration.motion.can_aim \
		and (not actor.finite_state_machine.current_state is Run and not actor.finite_state_machine.current_state is Slide)
	

func on_fired_weapon(_target_hitscan: Dictionary) -> void:
	add_camera_recoil()
	weapon_recoil.apply_recoil()
