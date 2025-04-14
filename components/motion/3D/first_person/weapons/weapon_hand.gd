@icon("res://components/motion/3D/first_person/weapons/icons/weapon_holder.svg")
class_name FirstPersonWeaponHand extends Node3D

signal drawed_weapon(weapon: FireArmWeapon)
signal stored_weapon(weapon: FireArmWeapon)

@export var actor: IndieBlueprintFirstPersonController
@export var weapon_sway: WeaponSway
@export var weapon_bob: WeaponBob
@export var weapon_tilt: WeaponTilt
@export var weapon_impulse: WeaponImpulse
@export var weapon_recoil: WeaponRecoil

var weapon_equipped: FireArmWeapon:
	set(value):
		if value != weapon_equipped:
			weapon_equipped = value
			
			if is_node_ready():
				if weapon_equipped:
					enable_weapon_motion()
				else:
					disable_weapon_motion()
					
			set_physics_process(weapon_equipped != null)
			set_process_unhandled_input(weapon_equipped != null)
					
var camera_recoil_target_rotation: Vector3
var camera_current_recoil_rotation: Vector3
var is_busy: bool = false


func _unhandled_input(_event: InputEvent) -> void:
	if weapon_equipped:
		if weapon_equipped.weapon_configuration.motion.keep_pressed_to_aim:
			if IndieBlueprintInputHelper.action_pressed_and_exists(weapon_equipped.weapon_configuration.motion.aim_input_action):
				weapon_equipped.current_aim_state = FireArmWeapon.AimStates.Aim
			else:
				weapon_equipped.current_aim_state = FireArmWeapon.AimStates.Holded
		else:
			if IndieBlueprintInputHelper.action_just_pressed_and_exists(weapon_equipped.weapon_configuration.motion.aim_input_action):
				if weapon_equipped.current_aim_state == FireArmWeapon.AimStates.Holded:
					weapon_equipped.current_aim_state = FireArmWeapon.AimStates.Aim
				else:
					weapon_equipped.current_aim_state = FireArmWeapon.AimStates.Holded

		
func _ready() -> void:
	if weapon_equipped:
		enable_weapon_motion()
	else:
		disable_weapon_motion()
	
	set_physics_process(weapon_equipped != null)
	set_process_unhandled_input(weapon_equipped != null)

		
func _physics_process(delta: float) -> void:
	if weapon_equipped:
		apply_camera_recoil(delta)
		aim(delta)


#region Weapon equip
func equip(new_weapon: FireArmWeapon) -> void:
	is_busy = true
	unequip()
	
	if not new_weapon.is_inside_tree():
		weapon_recoil.add_child(new_weapon)
		new_weapon.position = new_weapon.hand_position
	
	await get_tree().physics_frame
	
	weapon_equipped = new_weapon
	weapon_equipped.show()
	weapon_equipped.process_mode = Node.PROCESS_MODE_INHERIT
	weapon_equipped.active = true
	
	_connnect_weapon_signals(weapon_equipped)
		
	if weapon_equipped.weapon_mesh.draw_animation():
		await weapon_equipped.weapon_mesh.animation_player.animation_finished
	
	is_busy = false
	drawed_weapon.emit(weapon_equipped)
	

func unequip() -> void:
	is_busy = true
	
	if weapon_equipped:
		weapon_equipped.active = false
			
		_disconnect_weapon_signals(weapon_equipped)
		
		if weapon_equipped.weapon_mesh.store_animation():
			await weapon_equipped.weapon_mesh.animation_player.animation_finished
		
		weapon_equipped.hide()
		weapon_equipped.process_mode = Node.PROCESS_MODE_DISABLED
	
		stored_weapon.emit(weapon_equipped)
		weapon_equipped = null
		
	is_busy = false


func change_weapons_to_hand(other_hand: FirstPersonWeaponHand) -> void:
	if other_hand != self:
		is_busy = true
		
		for weapon: FireArmWeapon in IndieBlueprintNodeTraversal.find_nodes_of_custom_class(weapon_recoil, FireArmWeapon):
			weapon.reparent(other_hand.weapon_recoil, false)
			
			await get_tree().physics_frame
			weapon.position = Vector3.ZERO
			other_hand.equip(weapon)
	
		is_busy = false


func is_empty() -> bool:
	return IndieBlueprintNodeTraversal\
		.find_nodes_of_custom_class(weapon_recoil, FireArmWeapon)\
		.filter(func(weapon: FireArmWeapon): return weapon.active).size() == 0
#endregion


func aim(delta: float) -> void:
	if weapon_can_aim():
		match weapon_equipped.current_aim_state:
			FireArmWeapon.AimStates.Aim:
				if weapon_equipped.weapon_configuration.motion.center_weapon_on_aim:
					weapon_equipped.position = weapon_equipped.position.lerp(weapon_equipped.aim_position, weapon_equipped.weapon_configuration.motion.aim_smoothing * delta)
				
				rotation = Vector3.ZERO
				
				actor.camera_controller.camera.fov = lerpf(
					actor.camera_controller.camera.fov, 
					weapon_equipped.weapon_configuration.motion.zoom_level_on_aim, 
					weapon_equipped.weapon_configuration.motion.aim_smoothing * delta
				)
				
			FireArmWeapon.AimStates.Holded:
				actor.camera_controller.camera.fov = lerpf(
					actor.camera_controller.camera.fov, 
					actor.original_camera_fov,
					weapon_equipped.weapon_configuration.motion.aim_smoothing * delta
				)
				
				if weapon_equipped.weapon_configuration.motion.center_weapon_on_aim:
					weapon_equipped.position = weapon_equipped.position.lerp(
						weapon_equipped.hand_position, 
						weapon_equipped.weapon_configuration.motion.aim_smoothing * delta
					)
	

func weapon_can_aim() -> bool:
	return is_processing_unhandled_input() \
		and weapon_equipped \
		and weapon_equipped.weapon_configuration.motion.can_aim \
		and not actor.state_machine.current_state is FirstPersonRunState \
		and not actor.state_machine.current_state is FirstPersonSlideState
	

#region Recoil
func apply_camera_recoil(delta: float) -> void:
	if camera_recoil_can_be_applied():
		## Head recoil to affect on accuracy moving the current camera 3d
		camera_recoil_target_rotation = lerp(
			camera_recoil_target_rotation,
			Vector3.ZERO,
			weapon_equipped.weapon_configuration.motion.camera_recoil_lerp_speed * delta
		)
		
		camera_current_recoil_rotation = lerp(
			camera_current_recoil_rotation, 
			camera_recoil_target_rotation, 
			weapon_equipped.weapon_configuration.motion.camera_recoil_snap_amount * delta
		)
		
		actor.head.basis = Quaternion.from_euler(camera_current_recoil_rotation)


func add_camera_recoil() -> void:
	if camera_recoil_can_be_applied():
		var recoil_amount: Vector3 = weapon_equipped.weapon_configuration.motion.camera_recoil_amount
		
		camera_recoil_target_rotation += Vector3(
			recoil_amount.x, 
			randf_range(-recoil_amount.y, recoil_amount.y),
			randf_range(-recoil_amount.z, recoil_amount.z),
		)


func camera_recoil_can_be_applied() -> bool:
	return weapon_equipped \
		and weapon_equipped.weapon_configuration.motion.camera_recoil_enabled \
		and actor.head

#endregion

#region Weapon motion
func _prepare_weapon_motion(weapon_configuration: FireArmWeaponConfiguration) -> void:
	if weapon_configuration.motion.sway_enabled and weapon_sway:
		weapon_sway.base_multiplier = weapon_configuration.motion.sway_base_multiplier
		weapon_sway.aim_multiplier = weapon_configuration.motion.sway_aim_multiplier
		weapon_sway.canted_multiplier = weapon_configuration.motion.sway_canted_multiplier
		weapon_sway.smoothing = weapon_configuration.motion.sway_smoothing
	else:
		disable_weapon_sway()
		
	if weapon_configuration.motion.bob_enabled:
		weapon_bob.headbob_intensity = weapon_configuration.motion.bob_intensity
		weapon_bob.noise = weapon_configuration.motion.bob_noise
		weapon_bob.target_frequency = weapon_configuration.motion.bob_frequency
		weapon_bob.target_amplitude = weapon_configuration.motion.bob_amplitude
	else:
		disable_weapon_bob()
	
	if weapon_configuration.motion.tilt_enabled:
		weapon_tilt.tilt_horizontal = weapon_configuration.motion.tilt_horizontal
		weapon_tilt.tilt_vertical = weapon_configuration.motion.tilt_vertical
		weapon_tilt.tilt_smoothing = weapon_configuration.motion.tilt_smoothing
		weapon_tilt.push_smoothing = weapon_configuration.motion.tilt_push_smoothing
		weapon_tilt.hip_push_backward = weapon_configuration.motion.tilt_hip_push_backward
		weapon_tilt.hip_push_forward = weapon_configuration.motion.tilt_hip_push_forward
		weapon_tilt.inverted = weapon_configuration.motion.tilt_inverted
	else:
		disable_weapon_tilt()
	
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
		disable_weapon_impulse()
	
	if weapon_configuration.motion.recoil_enabled:
		weapon_recoil.kick = weapon_configuration.motion.recoil_kick
		weapon_recoil.kick_power = weapon_configuration.motion.recoil_kick_power
		weapon_recoil.kick_recovery = weapon_configuration.motion.recoil_kick_recovery
		weapon_recoil.rotation_power = weapon_configuration.motion.recoil_rotation_power
		weapon_recoil.rotation_recovery = weapon_configuration.motion.recoil_rotation_recovery
		weapon_recoil.horizontal_recoil = weapon_configuration.motion.recoil_horizontal
		weapon_recoil.vertical_recoil = weapon_configuration.motion.recoil_vertical
	else:
		disable_weapon_recoil()


func enable_weapon_motion() -> void:
	enable_weapon_sway()
	enable_weapon_bob()
	enable_weapon_tilt()
	enable_weapon_impulse()
	enable_weapon_recoil()


func disable_weapon_motion() -> void:
	disable_weapon_sway()
	disable_weapon_bob()
	disable_weapon_tilt()
	disable_weapon_impulse()
	disable_weapon_recoil()


func enable_weapon_sway() -> void:
	if weapon_sway:
		weapon_sway.enable()


func disable_weapon_sway() -> void:
	if weapon_sway:
		weapon_sway.disable()
		
		
func enable_weapon_bob() -> void:
	if weapon_bob:
		weapon_bob.enable()


func disable_weapon_bob() -> void:
	if weapon_bob:
		weapon_bob.disable()

	
func enable_weapon_tilt() -> void:
	if weapon_tilt:
		weapon_tilt.enable()


func disable_weapon_tilt() -> void:
	if weapon_tilt:
		weapon_tilt.disable()


func enable_weapon_impulse() -> void:
	if weapon_impulse:
		weapon_impulse.enable()


func disable_weapon_impulse() -> void:
	if weapon_impulse:
		weapon_impulse.disable()
		
		
func enable_weapon_recoil() -> void:
	if weapon_recoil:
		weapon_recoil.enable()


func disable_weapon_recoil() -> void:
	if weapon_recoil:
		weapon_recoil.disable()
#endregion


func _connnect_weapon_signals(weapon: FireArmWeapon) -> void:
	if not weapon.fired.is_connected(on_fired_weapon):
		weapon.fired.connect(on_fired_weapon)

	if not weapon.reload_started.is_connected(on_weapon_reload_started):
			weapon.reload_started.connect(on_weapon_reload_started)

	if not weapon.reload_finished.is_connected(on_weapon_reload_finished):
		weapon.reload_finished.connect(on_weapon_reload_finished)
		
	if not weapon.aimed.is_connected(on_weapon_aimed):
		weapon.aimed.connect(on_weapon_aimed)
		
	if not weapon.aim_finished.is_connected(on_weapon_aim_finished):
		weapon.aim_finished.connect(on_weapon_aim_finished)


func _disconnect_weapon_signals(weapon: FireArmWeapon) -> void:
	if weapon.fired.is_connected(on_fired_weapon):
		weapon.fired.disconnect(on_fired_weapon)

	if weapon.reload_started.is_connected(on_weapon_reload_started):
		weapon.reload_started.disconnect(on_weapon_reload_started)

	if weapon.reload_finished.is_connected(on_weapon_reload_finished):
		weapon.reload_finished.disconnect(on_weapon_reload_finished)

	if weapon.aimed.is_connected(on_weapon_aimed):
		weapon.aimed.disconnect(on_weapon_aimed)
		
	if weapon.aim_finished.is_connected(on_weapon_aim_finished):
		weapon.aim_finished.disconnect(on_weapon_aim_finished)

#region Signal callbacks
func on_fired_weapon(_target_hitscan: RaycastResult) -> void:
	add_camera_recoil()
	weapon_recoil.apply_recoil()


func on_weapon_reload_started() -> void:
	is_busy = true
	
	
func on_weapon_reload_finished() -> void:
	is_busy = false
	
	
func on_weapon_aimed() -> void:
	disable_weapon_sway()
	disable_weapon_tilt()
	
	
func on_weapon_aim_finished() -> void:
	enable_weapon_sway()
	enable_weapon_tilt()
	
#endregion
