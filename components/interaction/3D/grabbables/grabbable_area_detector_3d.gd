class_name GrabbableAreaDetector3D extends Area3D


func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = GameGlobals.grabbables_collision_layer
	monitorable = false
	monitoring = true
	priority = 2
