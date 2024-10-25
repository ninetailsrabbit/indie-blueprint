class_name FireArmWeaponBullet extends Resource


@export_group("Bullet")
## The bullet scene to spawn in the world when weapon shoots
@export var scene: PackedScene 
## The base damage that is applied to the bullet from this weapon
@export var base_damage: int = 10
## The impact force to apply when collides with rigid bodies
@export var impact_force: Vector3 = Vector3.ONE
## If the bullet reachs a collision point below this distance, a multiplier it's applied to the damage
@export var close_distance_to_apply_damage_multiplier: int = 25
## The closer the shot this multiplier will be applied.
@export var close_distance_damage_multiplier: float = 1.5
## In the form of [distance_in_meters, multiplier] each time this bullet travel the setted distance, a multiplier is applied usually to reduce the damage
@export var multiplier_for_distance_traveled: Array[float] = [50, 1.0]
