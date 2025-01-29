class_name IntegerScalingCheckbox extends CheckBox

## For some reason the CONTENT_SCALE_STRETCH enums are not recognized on the editor
## So 1 means integer scaling is enabled and 0 disabled
func _ready() -> void:
	button_pressed = get_tree().root.content_scale_stretch == 1
	toggled.connect(on_integer_scaling_changed)


@warning_ignore("int_as_enum_without_cast")
func on_integer_scaling_changed(enabled: bool) -> void:
	get_tree().root.content_scale_stretch = int(enabled)
	SettingsManager.update_graphics_section(GameSettings.IntegerScalingSetting, get_tree().root.content_scale_stretch)
