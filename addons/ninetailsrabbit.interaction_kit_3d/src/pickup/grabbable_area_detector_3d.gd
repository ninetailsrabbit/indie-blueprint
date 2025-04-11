class_name GrabbableAreaDetector3D extends Area3D


func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = InteractionKit3DPluginUtilities.layer_to_value(ProjectSettings.get_setting(InteractionKit3DPluginSettings.GrabbablesCollisionLayerSetting))
	monitorable = false
	monitoring = true
	priority = 2
