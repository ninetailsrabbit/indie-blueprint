@icon("res://components/motion/3D/first-person/shooter/weapons/weapon.svg")
class_name FireArmWeapon extends Node3D

const GroupName = "firearm-weapons"

signal stored
signal drawed
signal fired(target_hitscan: Dictionary)
signal reloaded
signal out_of_ammo
signal aim
signal aim_finished

@export var camera: Camera3D
@export var weapon_mesh: FireArmWeaponMesh
@export var weapon_configuration: FireArmWeaponConfiguration:
	set(value):
		if value != weapon_configuration:
			weapon_configuration = value
			active = weapon_configuration != null
@export var muzzle_flash_scene: PackedScene = preload("res://components/motion/3D/first-person/shooter/weapons/muzzle/emitter/muzzle_flash.tscn")
 

enum CombatStates {
	Neutral,
	Fire,
	Reload,
}

enum AimStates {
	Aim,
	Holded
}

var current_combat_state: CombatStates = CombatStates.Neutral
var current_aim_state: AimStates = AimStates.Holded:
	set(value):
		if value != current_aim_state:
			current_aim_state = value
			
			if current_aim_state == AimStates.Aim:
				aim.emit()
				
			if current_aim_state == AimStates.Holded:
				aim_finished.emit()
			
var original_weapon_position: Vector3
var original_weapon_rotation: Vector3

var fire_timer: float = 0.0
var fire_impulse_timer: float = 0.0

var active: bool = true:
	set(value):
		if value != active:
			active = value
			
			set_physics_process(active)
			set_process_unhandled_input(active)

var hitscan_result: Dictionary = {}

var bullet_impact_manager: BulletImpactManager

func _unhandled_input(_event: InputEvent) -> void:
	if weapon_configuration.motion.keep_pressed_to_aim:
		if InputHelper.action_pressed_and_exists(weapon_configuration.motion.aim_input_action):
			current_aim_state = AimStates.Aim
		else:
			current_aim_state = AimStates.Holded
	else:
		if InputHelper.action_just_pressed_and_exists(weapon_configuration.motion.aim_input_action):
			current_aim_state = AimStates.Aim if current_aim_state == AimStates.Holded else AimStates.Holded
		

func _enter_tree() -> void:
	add_to_group(GroupName)
	
	active = weapon_configuration != null
	
	bullet_impact_manager = BulletImpactManager.new()
	add_child(bullet_impact_manager)


func _ready() -> void:
	original_weapon_position = position
	original_weapon_rotation = rotation

	set_physics_process(active)
	set_process_unhandled_input(active)
	

func _physics_process(delta: float) -> void:
	if (fire_timer < weapon_configuration.fire.fire_rate):
		fire_timer += delta
		
	hitscan_result = hitscan()
	
	match weapon_configuration.fire.burst_type:
		weapon_configuration.fire.BurstTypes.Single:
			if InputHelper.action_just_pressed_and_exists(InputControls.Shoot):
				shoot(hitscan_result)
		weapon_configuration.fire.BurstTypes.BurstFire:
			if InputHelper.action_just_pressed_and_exists(InputControls.Shoot):
				for i in range(weapon_configuration.fire.number_of_shoots):
					shoot(hitscan_result, weapon_configuration.fire.number_of_shoots == 1)
		weapon_configuration.fire.BurstTypes.ThreeRoundBurst:
			if InputHelper.action_just_pressed_and_exists(InputControls.Shoot):
				for i in range(3):
					shoot(hitscan_result, false)
					
		weapon_configuration.fire.BurstTypes.FiveRoundBurst:
			if InputHelper.action_just_pressed_and_exists(InputControls.Shoot):
				for i in range(5):
					shoot(hitscan_result, false)
		weapon_configuration.fire.BurstTypes.Automatic:
			if InputHelper.action_pressed_and_exists(InputControls.Shoot):
				shoot(hitscan_result)
		weapon_configuration.fire.BurstTypes.SemiAutomatic:
			if InputHelper.action_pressed_and_exists(InputControls.Shoot):
				shoot(hitscan_result)
		
	
func shoot(target_hitscan: Dictionary = hitscan_result, use_fire_timer: bool = true) -> void:
	if _can_shoot(use_fire_timer):
		current_combat_state = CombatStates.Fire
		
		if camera and weapon_configuration.motion.camera_shake_enabled:
			camera.trauma(weapon_configuration.motion.camera_shake_time, weapon_configuration.motion.camera_shake_magnitude)
		
		weapon_configuration.ammo.current_ammunition -= weapon_configuration.fire.bullets_per_shoot
		weapon_configuration.ammo.current_magazine -= weapon_configuration.fire.bullets_per_shoot
		fire_timer = 0.0
		
		muzzle_effect()
		
		if weapon_configuration.fire.bullets_per_shoot == 1:
			spawn_bullet(target_hitscan)
		else:
			for i in range(weapon_configuration.fire.bullets_per_shoot):
				var spread_direction: Vector3 = Camera3DHelper.forward_direction(camera).rotated(VectorHelper.generate_3d_random_direction(), deg_to_rad(randf_range(-weapon_configuration.fire.bullet_spread_degrees, weapon_configuration.fire.bullet_spread_degrees)))
				var spreaded_hitscan_origin: Vector3 = camera.project_ray_origin(WindowManager.screen_center()) + spread_direction
				var spreaded_hitscan_to: Vector3 = camera.project_ray_normal(WindowManager.screen_center()) + spread_direction * weapon_configuration.fire.fire_range
				
				spawn_bullet(create_hitscan(spreaded_hitscan_origin, spreaded_hitscan_to))
		
		fired.emit(target_hitscan)
		
	if weapon_configuration.fire.auto_reload_on_empty_magazine and weapon_configuration.ammo.magazine_empty():
		reload()


func spawn_bullet(target_hitscan: Dictionary = {}) -> void:
	if weapon_configuration.hitscan and weapon_configuration.projectile:
		_handle_hitscan_and_projectile_collision(target_hitscan)
	elif not weapon_configuration.hitscan and weapon_configuration.projectile:
		_handle_projectile_collision()
	elif weapon_configuration.hitscan and not weapon_configuration.projectile:
		_handle_hitscan_collision(target_hitscan)
		

func reload() -> void:
	if weapon_configuration.ammo.can_reload() and not current_combat_state == CombatStates.Reload:
		current_combat_state = CombatStates.Reload
		
		var ammo_needed = weapon_configuration.ammo.magazine_size - weapon_configuration.ammo.current_magazine
		
		## If there is more ammunition available than the current cartridge
		if weapon_configuration.ammo.current_ammunition >= ammo_needed:
			weapon_configuration.ammo.current_magazine = ammo_needed
			weapon_configuration.ammo.current_ammunition -= ammo_needed
			
		else: ## If the available ammunition is less than the ammunition needed to reload, the remaining ammunition is taken.
			weapon_configuration.ammo.current_magazine = weapon_configuration.ammo.current_ammunition
			weapon_configuration.ammo.current_ammunition = 0
		
		await weapon_mesh.reload_animation()
		reloaded.emit()
		
		current_combat_state = CombatStates.Neutral


func hitscan() -> Dictionary:
	if camera:
		var screen_center: Vector2i = WindowManager.screen_center()
		var origin = camera.project_ray_origin(screen_center)
		var to: Vector3 = origin + camera.project_ray_normal(screen_center) * weapon_configuration.fire.fire_range
		
		return create_hitscan(origin, to)
		
	return {}


func create_hitscan(origin: Vector3, to: Vector3) -> Dictionary:
	var hitscan_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		origin, 
		to,
		GameGlobals.world_collision_layer | GameGlobals.enemies_collision_layer
	)
	
	## TODO - MAYBE WE NEED TO HIT AREAS IN THE FUTURE ALSO
	hitscan_ray_query.collide_with_areas = true 
	hitscan_ray_query.collide_with_bodies = true
	
	return get_world_3d().direct_space_state.intersect_ray(hitscan_ray_query)


func muzzle_effect() -> void:
	if weapon_configuration.muzzle_texture and weapon_mesh.muzzle_marker:
		var muzzle: MuzzleFlash = muzzle_flash_scene.instantiate() as MuzzleFlash
		muzzle.setup_from_weapon_configuration(weapon_configuration)
		weapon_mesh.muzzle_marker.add_child(muzzle)



func _handle_hitscan_collision(target_hitscan: Dictionary) -> void:
## Only hitscan, spawn bullet decals on raycast collision points
	if not target_hitscan.is_empty():
		var collider = target_hitscan.get("collider")
		var adjusted_position = target_hitscan.get("position")
		
		if collider.collision_layer == GameGlobals.enemies_collision_layer:
			## Spawn the weapon bullet to use the hitbox on the hitscan collision point
			_handle_projectile_collision(0.0, adjusted_position)
		else:
			bullet_impact_manager.spawn_impact_from_hitscan(target_hitscan)

			if collider is RigidBody3D:
				collider.apply_impulse(weapon_configuration.bullet.impact_force * Camera3DHelper.forward_direction(camera), -adjusted_position)
			

func _handle_hitscan_and_projectile_collision(target_hitscan: Dictionary) -> void:
		_handle_hitscan_collision(target_hitscan)
		
		## If no collision is detected, the bullets are spawned on the weapon fire range limit
		if target_hitscan.is_empty() and weapon_configuration.spawn_bullets_on_empty_hitscan:
			_handle_projectile_collision(weapon_configuration.fire.fire_range if weapon_configuration.spawn_bullets_on_fire_range_limit else 0.0)
		

func _handle_projectile_collision(spawn_range: float = 0.0, initial_position: Vector3 = Vector3.ZERO) -> void:
	if weapon_configuration.bullet.scene:
		var bullet: Bullet = weapon_configuration.bullet.scene.instantiate() as Bullet
		bullet.setup(self, Camera3DHelper.forward_direction(camera), initial_position)
		weapon_mesh.barrel_marker.add_child(bullet)
		bullet.global_position += bullet.direction * spawn_range


func _can_shoot(use_fire_timer: bool = true) -> bool:
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
