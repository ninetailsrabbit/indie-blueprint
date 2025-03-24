@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("IndieBlueprintWindowManager", "res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/autoloads/viewport/window_manager.gd")
	
	add_custom_type(
		"IndieBlueprintSmartDecal", 
		"Decal", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/3D/decals/smart_decal.gd"),
		null
	)
	
	add_custom_type(
		"IndieBlueprintDraggable2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/drag/draggable_2d.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/drag/draggable_2d.svg")
	)
	
	add_custom_type(
		"IndieBlueprintOrbitComponent2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/orbit/orbit.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/orbit/orbit.svg")
	)
	
	add_custom_type(
		"IndieBlueprintRotatorComponent2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/rotation/rotator.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/rotation/rotator.svg")
	)
	
	add_custom_type(
		"IndieBlueprintSwingComponent2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/swing/swing.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/swing/swing.svg")
	)
	
	add_custom_type(
		"IndieBlueprintFollowComponent2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/follow/follow.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/follow/follow.svg")
	)


func _exit_tree() -> void:
	remove_custom_type("IndieBlueprintFollowComponent2D")
	remove_custom_type("IndieBlueprintSwingComponent2D")
	remove_custom_type("IndieBlueprintRotatorComponent2D")
	remove_custom_type("IndieBlueprintOrbitComponent2D")
	remove_custom_type("IndieBlueprintDraggable2D")
	remove_custom_type("IndieBlueprintSmartDecal")
	
	remove_autoload_singleton("IndieBlueprintWindowManager")
