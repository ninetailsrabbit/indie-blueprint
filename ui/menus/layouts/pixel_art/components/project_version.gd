class_name ProjectVersion extends Label

@export var default_version: String = "1.0.0"


func _ready() -> void:
	text = ProjectSettings.get_setting("application/config/version", default_version)
