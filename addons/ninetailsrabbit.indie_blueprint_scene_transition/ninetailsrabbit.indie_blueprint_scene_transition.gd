@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("IndieBlueprintSceneTransitioner", "res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/scene_transitioner.tscn")


func _exit_tree() -> void:
	remove_autoload_singleton("IndieBlueprintSceneTransitioner")
