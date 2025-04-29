extends Node

@export_file("*.tscn") var next_scene: String = ""

@onready var content_warnings: IndieBlueprintContentWarnings = $ContentWarnings


func _ready() -> void:
	content_warnings.all_content_warnings_displayed.connect(on_all_content_warnings_displayed)


func on_all_content_warnings_displayed() -> void:
	if not next_scene.is_empty():
		IndieBlueprintSceneTransitioner.transition_to(next_scene)
