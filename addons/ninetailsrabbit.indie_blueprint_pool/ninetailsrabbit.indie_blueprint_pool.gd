@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"IndieBlueprintObjectPool",
		"Node",
		preload("res://addons/ninetailsrabbit.indie_blueprint_pool/src/object_pool.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_pool/icons/object_pool.svg")
	)
	
	add_autoload_singleton("IndieBlueprintObjectPoolManager", "res://addons/ninetailsrabbit.indie_blueprint_pool/src/object_pool_manager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("IndieBlueprintObjectPoolManager")
	remove_custom_type("IndieBlueprintObjectPool")
