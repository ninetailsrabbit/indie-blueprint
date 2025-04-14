@icon("res://components/motion/3D/first_person/weapons/icons/weapon.svg")
class_name FireArmWeapon extends Node3D

const GroupName: StringName = &"firearm-weapons"

enum WeaponCategory {
	Pistol,
	Revolver,
	AssaultRifle,
	SubMachineGun,
	SniperRifle,
	Shotgun,
	GrenadeLauncher,
	RocketLauncher,
	Melee,
	MeleeBlunt,
	MeleeSharpen
}

enum CombatStates {
	Neutral,
	Fire,
	Reload,
}

enum AimStates {
	Aim,
	Holded
}


signal fired(target_hitscan: RaycastResult)
signal reload_started
signal reload_finished
signal out_of_ammo
signal aimed
signal aim_finished

@export var id: StringName
@export var category: WeaponCategory = WeaponCategory.Pistol
@export var shoot_input_action: StringName = InputControls.Shoot
@export var reload_input_action: StringName = InputControls.Reload
@export var weapon_mesh: WeaponMesh
@export var weapon_configuration: FireArmWeaponConfiguration
@export var muzzle_flash_scene: PackedScene = preload("res://components/motion/3D/first_person/weapons/muzzle/emitter/muzzle_flash.tscn")
@export var hand_position: Vector3 = Vector3.ZERO
@export var aim_position: Vector3 = Vector3.ZERO

var current_combat_state: CombatStates = CombatStates.Neutral
var current_aim_state: AimStates = AimStates.Holded:
	set(value):
		if value != current_aim_state:
			current_aim_state = value
			
			if current_aim_state == AimStates.Aim:
				aimed.emit()
				
			if current_aim_state == AimStates.Holded:
				aim_finished.emit()
			
var original_weapon_position: Vector3
var original_weapon_rotation: Vector3

var fire_timer: float = 0.0
var fire_impulse_timer: float = 0.0

## This variable is useful to force this weapon to not shoot
## Usually when the player enters a state (e.g Run) and we want to lock the shoot
var lock_shoot: bool = false
var active: bool = true:
	set(value):
		if value != active:
			active = value
			
			set_physics_process(active)
			set_process_unhandled_input(active)


func _unhandled_input(_event: InputEvent) -> void:
	if IndieBlueprintInputHelper.action_just_pressed_and_exists(reload_input_action):
		reload()
		
func _enter_tree() -> void:
	add_to_group(GroupName)
	
	
func _ready() -> void:
	assert(weapon_mesh != null, "FirearmWeapon: The weapon with id %s does not have a weapon mesh attached" % id)
	assert(weapon_configuration != null, "FirearmWeapon: The weapon with id %s not have a weapon configuration set" % id)
	
	original_weapon_position = position
	original_weapon_rotation = rotation

	set_physics_process(active)
	set_process_unhandled_input(active)


func _physics_process(delta: float) -> void:
	if (fire_timer < weapon_configuration.fire.fire_rate):
		fire_timer += delta
		
	match weapon_configuration.fire.burst_type:
		weapon_configuration.fire.BurstTypes.Single:
			if IndieBlueprintInputHelper.action_just_pressed_and_exists(shoot_input_action):
				shoot(hitscan())
				
		weapon_configuration.fire.BurstTypes.BurstFire:
			if IndieBlueprintInputHelper.action_just_pressed_and_exists(shoot_input_action):
				for i in range(weapon_configuration.fire.number_of_shoots):
					shoot(hitscan(), weapon_configuration.fire.number_of_shoots == 1)
					
		weapon_configuration.fire.BurstTypes.ThreeRoundBurst:
			if IndieBlueprintInputHelper.action_just_pressed_and_exists(shoot_input_action):
				for i in range(3):
					shoot(hitscan(), false)
					
		weapon_configuration.fire.BurstTypes.FiveRoundBurst:
			if IndieBlueprintInputHelper.action_just_pressed_and_exists(shoot_input_action):
				for i in range(5):
					shoot(hitscan(), false)
					
		## TODO - DETERMINE WHAT'S THE DIFFERENCE BETWEEN AUTOMATIC AND SEMI-AUTOMATIC
		weapon_configuration.fire.BurstTypes.Automatic:
			if IndieBlueprintInputHelper.action_pressed_and_exists(shoot_input_action):
				shoot(hitscan())
				
		weapon_configuration.fire.BurstTypes.SemiAutomatic:
			if IndieBlueprintInputHelper.action_pressed_and_exists(shoot_input_action):
				shoot(hitscan())


func shoot(target_hitscan: RaycastResult, use_fire_timer: bool = true) -> void:
	if can_shoot(use_fire_timer):
		current_combat_state = CombatStates.Fire
		weapon_configuration.ammo.current_ammunition -= weapon_configuration.fire.bullets_per_shoot
		weapon_configuration.ammo.current_magazine -= weapon_configuration.fire.bullets_per_shoot
		fire_timer = 0.0
		
		muzzle_effect()
		
		if weapon_configuration.bullet.trace_scene and IndieBlueprintMathHelper.chance(weapon_configuration.bullet.trace_display_chance / 100.0):
			var trace: BulletTrace = weapon_configuration.bullet.trace_scene.instantiate() as BulletTrace
			trace.alive_time = weapon_configuration.bullet.trace_alive_time
			trace.speed = weapon_configuration.bullet.trace_speed
			weapon_mesh.barrel_marker.add_child(trace)
			
		if weapon_configuration.fire.bullets_per_shoot == 1:
			spawn_bullet(target_hitscan)
		else:
			for i in range(weapon_configuration.fire.bullets_per_shoot):
				var camera: Camera3D = get_viewport().get_camera_3d()
				
				var spread_direction: Vector3 = IndieBlueprintCamera3DHelper.forward_direction(camera)\
					.rotated(
						IndieBlueprintVectorHelper.generate_3d_random_direction(), 
						deg_to_rad(randf_range(-weapon_configuration.fire.bullet_spread_degrees, 
						weapon_configuration.fire.bullet_spread_degrees))
						)
						
				var spreaded_hitscan_origin: Vector3 = camera.project_ray_origin(IndieBlueprintWindowManager.screen_center()) + spread_direction
				var spreaded_hitscan_to: Vector3 = camera.project_ray_normal(IndieBlueprintWindowManager.screen_center()) + spread_direction * weapon_configuration.fire.fire_range
				
				spawn_bullet(create_hitscan(spreaded_hitscan_origin, spreaded_hitscan_to))
		
		if weapon_configuration.fire.auto_reload_on_empty_magazine and weapon_configuration.ammo.magazine_empty():
			reload()
			
		fired.emit(target_hitscan)
		IndieBlueprintGlobalGameEvents.weapon_fired.emit(self, target_hitscan)


func spawn_bullet(target_hitscan: RaycastResult) -> void:
	if weapon_configuration.hitscan and weapon_configuration.projectile:
		_handle_hitscan_and_projectile_collision(target_hitscan)
	
	elif weapon_configuration.hitscan and not weapon_configuration.projectile:
		_handle_hitscan_collision(target_hitscan)

	elif not weapon_configuration.hitscan and weapon_configuration.projectile:
		_handle_projectile_collision()
			
			
func spawn_bullet_trace() -> void:
	if weapon_configuration.bullet.trace_scene \
		and IndieBlueprintMathHelper.chance(weapon_configuration.bullet.trace_display_chance / 100.0):
		
		var trace: BulletTrace = weapon_configuration.bullet.trace_scene.instantiate() as BulletTrace
		trace.alive_time = weapon_configuration.bullet.trace_alive_time
		trace.speed = weapon_configuration.bullet.trace_speed
		weapon_mesh.barrel_marker.add_child(trace)
		
			
func reload() -> void:
	if not weapon_configuration.ammo.infinite_mode and  weapon_configuration.ammo.can_reload() and not current_combat_state == CombatStates.Reload:
		current_combat_state = CombatStates.Reload
		
		reload_started.emit()
		
		var ammo_needed = weapon_configuration.ammo.magazine_size - weapon_configuration.ammo.current_magazine
		
		## If there is more ammunition available than the current cartridge
		if weapon_configuration.ammo.current_ammunition >= ammo_needed:
			weapon_configuration.ammo.current_magazine = ammo_needed
			weapon_configuration.ammo.current_ammunition -= ammo_needed
			
		else: ## If the available ammunition is less than the ammunition needed to reload, the remaining ammunition is taken.
			weapon_configuration.ammo.current_magazine = weapon_configuration.ammo.current_ammunition
			weapon_configuration.ammo.current_ammunition = 0
		
		if weapon_mesh.reload_animation():
			await weapon_mesh.animation_player.animation_finished
			
		reload_finished.emit()
		
		current_combat_state = CombatStates.Neutral

#region Hitscan
func hitscan() -> RaycastResult:
	var camera: Camera3D = get_viewport().get_camera_3d()
	
	if camera:
		var screen_center: Vector2i = IndieBlueprintWindowManager.screen_center()
		var origin = camera.project_ray_origin(screen_center)
		var to: Vector3 = origin + camera.project_ray_normal(screen_center) * weapon_configuration.fire.fire_range
		
		return create_hitscan(origin, to)
		
	return RaycastResult.new({})


func create_hitscan(origin: Vector3, to: Vector3) -> RaycastResult:
	var hitscan_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		origin, 
		to,
		IndieBlueprintGameGlobals.world_collision_layer | IndieBlueprintGameGlobals.enemies_collision_layer
	)
	
	## TODO - MAYBE WE NEED TO HIT AREAS IN THE FUTURE ALSO
	hitscan_ray_query.collide_with_areas = true 
	hitscan_ray_query.collide_with_bodies = true
	
	return RaycastResult.new(get_world_3d().direct_space_state.intersect_ray(hitscan_ray_query))


func _handle_hitscan_collision(target_hitscan: RaycastResult) -> void:
## Only hitscan, spawn bullet decals on raycast collision points
	if target_hitscan.collided():
		var collider = target_hitscan.collider
		var adjusted_position = target_hitscan.position
		
		if collider.collision_layer == IndieBlueprintGameGlobals.enemies_collision_layer:
			## Spawn the weapon bullet to use the hitbox on the hitscan collision point
			_handle_projectile_collision(0.0, adjusted_position)
		else:
			if collider is RigidBody3D:
				collider.apply_impulse(
					weapon_configuration.bullet.impact_force * IndieBlueprintCamera3DHelper.forward_direction(get_viewport().get_camera_3d()), 
					-adjusted_position
					)


func _handle_hitscan_and_projectile_collision(target_hitscan: RaycastResult) -> void:
		_handle_hitscan_collision(target_hitscan)
		
		## If no collision is detected, the bullets are spawned on the weapon fire range limit
		if weapon_configuration.spawn_bullets_on_empty_hitscan:
			_handle_projectile_collision(weapon_configuration.fire.fire_range if weapon_configuration.spawn_bullets_on_fire_range_limit else 0.0)
		

func _handle_projectile_collision(_spawn_range: float = 0.0, initial_position: Vector3 = Vector3.ZERO) -> void:
	if weapon_configuration.bullet.scene:
		var bullet: Bullet = weapon_configuration.bullet.scene.instantiate() as Bullet
		bullet.setup(self, IndieBlueprintCamera3DHelper.forward_direction(get_viewport().get_camera_3d()), initial_position)
		weapon_mesh.barrel_marker.add_child(bullet)

#endregion

func can_shoot(use_fire_timer: bool = true) -> bool:
	if lock_shoot:
		return false
		
		
	if not active:
		return false
		
	if use_fire_timer and fire_timer < weapon_configuration.fire.fire_rate:
		return false
		
	if current_combat_state == CombatStates.Reload:
		return false
		
	if not weapon_configuration.ammo.has_ammunition_to_shoot():
		out_of_ammo.emit()
		return false
		
	return true
	
	
func muzzle_effect() -> void:
	if weapon_configuration.muzzle_texture \
		and weapon_mesh.muzzle_marker \
		and weapon_mesh.muzzle_marker.get_child_count() == 0:
		var muzzle: MuzzleFlash = muzzle_flash_scene.instantiate() as MuzzleFlash
		muzzle.setup_from_weapon_configuration(weapon_configuration)
		weapon_mesh.muzzle_marker.add_child(muzzle)


func is_aiming() -> bool:
	return current_aim_state == AimStates.Aim


#region Category
func is_pistol() -> bool:
	return category == WeaponCategory.Pistol

func is_revolver() -> bool:
	return category == WeaponCategory.Revolver
	
func is_assault_riffle() -> bool:
	return category == WeaponCategory.AssaultRifle
	
func is_submachine_gun() -> bool:
	return category == WeaponCategory.SubMachineGun
	
func is_sniper_rifle() -> bool:
	return category == WeaponCategory.SniperRifle
	
func is_shotgun() -> bool:
	return category == WeaponCategory.Shotgun

func is_rocket_launcher() -> bool:
	return category == WeaponCategory.RocketLauncher
	
func is_grenade_launcher() -> bool:
	return category == WeaponCategory.GrenadeLauncher

func is_melee() -> bool:
	return category == WeaponCategory.Melee
	
func is_melee_blunt() -> bool:
	return category == WeaponCategory.MeleeBlunt
	
func is_melee_sharpen() -> bool:
	return category == WeaponCategory.MeleeSharpen
#endregion
