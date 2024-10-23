## The purpose of this class it's to manage what decal to paint based on the surface the bullet collides
class_name BulletImpactManager extends Node

#region Prefab decal scenes
const BulletHoleNormal: PackedScene = preload("res://components/motion/3D/first-person/shooter/weapons/bullets/decals/scenes/bullet_normal_decal.tscn")
const BulletHoleMetal: PackedScene = preload("res://components/motion/3D/first-person/shooter/weapons/bullets/decals/scenes/bullet_metal_decal.tscn")
#endregion

#region Impact scenes
const BulletBloodImpact: PackedScene = preload("res://components/motion/3D/first-person/shooter/weapons/bullets/impact/scenes/bullet_blood_impact.tscn")
const BulletSmokeImpact: PackedScene = preload("res://components/motion/3D/first-person/shooter/weapons/bullets/impact/scenes/bullet_impact_smoke.tscn")
#endregion

#region Available surfaces
const SurfaceNormalGroup: StringName = &"normal"
const SurfaceWoodGroup: StringName = &"wood"
const SurfaceMetalGroup: StringName = &"metal"
const SurfaceOrganicGroup: StringName = &"organic"
#endregion

var surface_decals: Dictionary = {
	SurfaceNormalGroup: BulletHoleNormal,
	SurfaceMetalGroup: BulletHoleMetal
}

var surface_impacts: Dictionary = {
	SurfaceNormalGroup: BulletSmokeImpact,
	SurfaceOrganicGroup: BulletBloodImpact
}


func spawn_impact_on(collider: Node3D, collision_point: Vector3, normal: Vector3) -> void:
	var collider_groups: Array[StringName] = collider.get_groups()
	
	for collider_surface_group: StringName in collider_groups:
		if collider_surface_group in surface_decals.keys():
			var impact_decal: SmartDecal = surface_decals[collider_surface_group].instantiate() as SmartDecal
		
			collider.add_child(impact_decal)
			impact_decal.global_position = collision_point
			impact_decal.adjust_to_normal(normal)
		
		if collider_surface_group in surface_impacts.keys():
			var impact_hit: BulletImpact = surface_impacts[collider_surface_group] as BulletImpact
			get_tree().root.add_child(impact_hit)
			impact_hit.global_position = collision_point
	
	
func spawn_impact_from_hitscan(hitscan: Dictionary) -> void:
	if not hitscan.is_empty() and DictionaryHelper.contain_all_keys(hitscan, ["collider", "position", "normal"]):
		spawn_impact_on(hitscan.collider, hitscan.position, hitscan.normal)
		

func spawn_impact_from_bullet(bullet: Bullet) -> void:
	if bullet.collided():
		spawn_impact_on(bullet.collider,  bullet.collision_points.front(),  bullet.collision_normals.front())
