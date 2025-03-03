@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("IndieBlueprintCameraTransitioner", "res://addons/ninetailsrabbit.indie_blueprint_camera_transitioner/src/camera_transitioner.tscn" )


func _exit_tree() -> void:
	remove_autoload_singleton("IndieBlueprintCameraTransitioner")
