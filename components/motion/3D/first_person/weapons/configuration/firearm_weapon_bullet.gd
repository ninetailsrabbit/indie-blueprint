class_name FireArmWeaponBullet extends Resource


## The bullet scene to spawn in the world when the weapon shoots
@export var scene: PackedScene 
## The bullet trace scene to spawn in the world when the weapon shoots
@export var trace_scene: PackedScene
## The display chance to display a bullet trace. Set to 100.0 to always shows when the weapon shoots
@export_range(0, 100.0, 0.01) var trace_display_chance: float = 50.0
@export var trace_speed: float = 50.0
@export var trace_alive_time: float = 1.0
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
