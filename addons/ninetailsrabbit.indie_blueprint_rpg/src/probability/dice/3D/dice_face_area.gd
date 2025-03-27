class_name IndieBlueprintDiceFaceArea extends Area3D

## The area collision layer on dice faces to detect the value
@export_range(1, 32, 1) var dice_face_collision_layer: int = 8
@export var value: int = 0


func _enter_tree() -> void:
	priority = 2
	monitorable = true
	monitoring = false
	collision_layer = IndieBlueprintRpgUtils.layer_to_value(dice_face_collision_layer)
	collision_mask = 0
