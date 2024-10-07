@icon("res://components/collisions/hitbox.svg")
class_name Hitbox3D extends Area3D


func _init() -> void:
	collision_mask = 0
	collision_layer = GameGlobals.hitboxes_collision_layer
	monitoring = false
	monitorable = true


func enable():
	set_deferred("monitorable", true)
	

func disable():
	set_deferred("monitorable", false)
