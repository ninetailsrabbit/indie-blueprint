@icon("res://components/collisions/hurtbox.svg")
class_name Hurtbox3D extends Area3D

signal hitbox_detected(hitbox: Hitbox3D)


func _init() -> void:
	monitoring = true
	monitorable = false
	collision_mask = GameGlobals.hitboxes_collision_layer
	

func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(hitbox: Hitbox3D) -> void:
	hitbox_detected.emit(hitbox)
