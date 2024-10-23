## The purpose of this class it's to manage what decal to paint based on the surface the bullet collides
class_name BulletImpactManager extends Node

#region Prefab decal scenes
const BulletHoleNormal: PackedScene = preload("res://components/motion/3D/first-person/shooter/weapons/bullets/decals/scenes/bullet_normal_decal.tscn")
const BulletHoleMetal: PackedScene = preload("res://components/motion/3D/first-person/shooter/weapons/bullets/decals/scenes/bullet_metal_decal.tscn")
#endregion

#region Available surfaces
const SurfaceNormalGroup: StringName = &"normal"
const SurfaceWoodGroup: StringName = &"wood"
const SurfaceMetalGroup: StringName = &"metal"
#endregion

var surface_decals: Dictionary = {
	SurfaceNormalGroup: BulletHoleNormal,
	SurfaceMetalGroup: BulletHoleMetal
}

var surface_impacts: Dictionary = {
	SurfaceNormalGroup: "",
	SurfaceMetalGroup: ""
}


func spawn_decal_on(collider: Node3D, collision_point: Vector3, normal: Vector3) -> void:
	var collider_groups: Array[StringName] = collider.get_groups()
	
	for surface_group: StringName in surface_decals:
		if surface_group in collider_groups:
			var impact_decal: SmartDecal = surface_decals[surface_group].instantiate() as SmartDecal
		
			collider.add_child(impact_decal)
			impact_decal.global_position = collision_point
			impact_decal.adjust_to_normal(normal)
			break

	
func spawn_decal_from_hitscan(hitscan: Dictionary) -> void:
	if not hitscan.is_empty() and DictionaryHelper.contain_all_keys(hitscan, ["collider", "position", "normal"]):
		spawn_decal_on(hitscan.collider, hitscan.position, hitscan.normal)


func spawn_decal_from_bullet(bullet: Bullet) -> void:
	if bullet.collided():
		spawn_decal_on(bullet.collider,  bullet.collision_points.front(),  bullet.collision_normals.front())
