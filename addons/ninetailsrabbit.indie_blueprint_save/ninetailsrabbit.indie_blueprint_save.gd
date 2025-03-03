@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("IndieBlueprintSaveManager", "res://addons/ninetailsrabbit.indie_blueprint_save/src/save_manager.gd")
	

func _exit_tree() -> void:
	remove_autoload_singleton("IndieBlueprintSaveManager")
