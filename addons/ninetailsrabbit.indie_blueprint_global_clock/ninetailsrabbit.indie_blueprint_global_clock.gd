@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("IndieBlueprintGlobalClock", "res://addons/ninetailsrabbit.indie_blueprint_global_clock/src/global_clock.tscn")

func _exit_tree() -> void:
	remove_autoload_singleton("IndieBlueprintGlobalClock")
