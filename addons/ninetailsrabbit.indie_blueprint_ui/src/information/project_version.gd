class_name IndieBlueprintProjectVersion extends Label

@export var default_version: String = "1.0.0"
@export var prefix: String = "v"
@export var suffix: String = ""

func _ready() -> void:
	text = "%s%s%s" % [prefix, ProjectSettings.get_setting("application/config/version", default_version), suffix]
