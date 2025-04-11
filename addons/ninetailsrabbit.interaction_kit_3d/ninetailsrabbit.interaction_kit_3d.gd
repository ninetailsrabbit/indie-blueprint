@tool
extends EditorPlugin


func _enter_tree() -> void:
	InteractionKit3DPluginSettings.set_interactable_collision_layer()
	InteractionKit3DPluginSettings.set_grabbable_collision_layer()
	
	
	add_custom_type(
		"Interactable3D",
		"Area3D",
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/src/interactable_3d.gd"),
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/assets/grabbable.svg")
	)
	
	add_custom_type(
		"Grabbable3D",
		"RigidBody3D",
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/src/pickup/grabbable_3d.gd"),
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/assets/grabbable.svg")
	)
	
	add_custom_type(
		"GrabbableAreaDetector3D",
		"Area3D",
		preload("src/pickup/grabbable_area_detector_3d.gd"),
		null
	)
	
	add_custom_type(
		"Grabber3D",
		"Node3D",
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/src/pickup/grabber_3d.gd"),
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/assets/grabber.svg")
	)
	
	add_custom_type(
		"GrabbableInteractor3D",
		"RayCast3D",
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/src/interactors/grabbable_raycast_interactor_3d.gd"),
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/assets/interactor_3d.svg")
	)
	
	add_custom_type(
		"RayCastInteractor3D",
		"RayCast3D",
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/src/interactors/raycast_interactor_3d.gd"),
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/assets/interactor_3d.svg")
	)
	
	add_custom_type(
		"MouseRayCastInteractor3D",
		"Node3D",
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/src/interactors/mouse_raycast_interactor_3d.gd"),
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/assets/interactor_3d.svg")
	)
	
	add_custom_type(
		"Door3D",
		"Node3D",
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/src/doors/door.gd"),
		preload("res://addons/ninetailsrabbit.interaction_kit_3d/assets/door.svg")
	)
	
	add_autoload_singleton("GlobalInteractionEvents", "res://addons/ninetailsrabbit.interaction_kit_3d/src/global_interaction_events.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("GlobalInteractionEvents")
	remove_custom_type("Door3D")
	
	remove_custom_type("MouseRayCastInteractor3D")
	remove_custom_type("RayCastInteractor3D")
	remove_custom_type("GrabbableInteractor3D")
	
	remove_custom_type("Grabber3D")
	remove_custom_type("GrabbableAreaDetector3D")
	remove_custom_type("Grabbable3D")
	remove_custom_type("Interactable3D")
