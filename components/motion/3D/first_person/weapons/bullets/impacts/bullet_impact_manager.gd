@icon("res://components/motion/3D/first_person/weapons/icons/bullet.svg")
extends Node

## A set of surfaces groups that points to a scene that display a bullet hole when collide
@export var surfaces: Dictionary[StringName, PackedScene] = {}
## A set of surfaces groups that points to a scene that display a impact paraticle when collide
@export var impacts: Dictionary[StringName, PackedScene] = {}


func _ready() -> void:
	IndieBlueprintGlobalGameEvents.weapon_fired.connect(on_weapon_fired)


func spawn_impact_on(collider: Node3D, collision_point: Vector3, normal: Vector3) -> void:
	var collider_groups: Array[StringName] = collider.get_groups()
	## Decal spawn
	for collider_surface_group: StringName in collider_groups:
		if collider_surface_group in surfaces.keys():
			var surface_decal: IndieBlueprintSmartDecal = surfaces[collider_surface_group].instantiate() as IndieBlueprintSmartDecal
		
			collider.add_child(surface_decal)
			surface_decal.position = collider.to_local(collision_point)
			surface_decal.adjust_to_normal(normal)
		
		## Impact spawn
		if collider_surface_group in impacts.keys():
			var impact_hit: BulletImpact = impacts[collider_surface_group].instantiate() as BulletImpact
			get_tree().root.add_child(impact_hit)
			impact_hit.global_position = collision_point
			
		#if collider_surface_group in surface_splatters.keys():
			#var world_collision: Dictionary = _calculate_splatter_spawn_position(collider, collision_point, 4.0)
			#
			#if DictionaryHelper.contain_all_keys(world_collision, ["position", "normal"]):
				#var splatter: SmartDecal = surface_splatters[collider_surface_group].pick_random().instantiate() as SmartDecal
				#
				#collider.add_child(splatter)
				#splatter.position = collider.to_local(world_collision["position"])
				#splatter.adjust_to_normal(world_collision["normal"])
		
	
func spawn_impact_from_hitscan(hitscan: RaycastResult) -> void:
	if hitscan.collided():
		spawn_impact_on(hitscan.collider, hitscan.position, hitscan.normal)
		

func spawn_impact_from_bullet(bullet: Bullet) -> void:
	if bullet.collided():
		spawn_impact_on(bullet.collider,  bullet.collision_points.front(),  bullet.collision_normals.front())


#func _calculate_splatter_spawn_position(collider: Node3D, collision_point: Vector3, distance: float = 4.0) -> Dictionary:
	#var hitscan_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		#collision_point, 
		#collision_point + VectorHelper.generate_3d_random_direction() * distance,
		#GameGlobals.world_collision_layer
	#)
	#
	#hitscan_ray_query.collide_with_areas = false 
	#hitscan_ray_query.collide_with_bodies = true
	#
	#return collider.get_world_3d().direct_space_state.intersect_ray(hitscan_ray_query)
		#

## The projectile impact is handled on the bullet itself using this manager
func on_weapon_fired(weapon: FireArmWeapon, hitscan: RaycastResult) -> void:
	if weapon.weapon_configuration.hitscan:
		spawn_impact_from_hitscan(hitscan)
