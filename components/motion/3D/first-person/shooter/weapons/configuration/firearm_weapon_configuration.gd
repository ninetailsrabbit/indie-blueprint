class_name FireArmWeaponConfiguration extends Resource


@export var name: String = ""
@export var description: String = ""
@export_range(0, 100, 0.1) var durability: float = 95.0
@export_range(0, 100, 0.1) var accuracy: float = 90.0
## When enabled the hitscan it's active for this weapon projected on the distance defined by the variable fire_range
@export var hitscan: bool = true
## When enabled a projectile it's spawned on the barrel marker of the weapon mesh that can interat with the physic world. 
## The bullet scene defined in this resource it's the one spawned as projectile
@export var projectile: bool = false
## When projectile and this variable is enabled and the weapon shoot but the hitscan collision it's empty, the bullets are spawned on the limit of this weapon fire range where the hitscan it's pointing at
@export var spawn_bullets_on_empty_hitscan: bool = true
## When enabled, if the hitscan does not collide with anything a bullet it's spawned on the fire range limit as rigid body
@export var spawn_bullets_on_fire_range_limit: bool = false
@export_group("Configuration")
@export var ammo: FireArmWeaponAmmo
@export var bullet: FireArmWeaponBullet
@export var fire: FireArmWeaponFire
@export var motion: FireArmWeaponMotion
@export_group("Muzzle flash")
@export var muzzle_texture: Texture2D
@export var muzzle_lifetime: float = 0.03
@export var muzzle_min_size: Vector2 = Vector2(0.05, 0.05)
@export var muzzle_max_size: Vector2 = Vector2(0.35, 0.35)
@export var muzzle_emit_on_ready: bool = true
#@export_category("Bullet decal")
#@export var enable_bullet_decal: bool = true
#@export var bullet_decal_texture: Texture2D
#@export var bullet_decal_min_size: Vector3 = Vector3(0.03, 0.03, 0.03)
#@export var bullet_decal_max_size: Vector3 = Vector3(0.03, 0.03, 0.03)
#@export var bullet_decal_fade_after: float = 3.0
#@export var bullet_decal_fade_out_time: float = 1.5
#@export_category("Bullet Impact")
### TODO - Manage the hits based on the surface it's colliding instead of a preloaded scene
#@export var hit_scene: PackedScene = preload("res://scenes/world/weapons/bullets/impact/Hit.tscn")
#@export var use_impact_hit: bool = true
