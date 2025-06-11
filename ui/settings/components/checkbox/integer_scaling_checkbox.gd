class_name IntegerScalingCheckbox extends SettingCheckbox

## For some reason the CONTENT_SCALE_STRETCH enums are not recognized on the editor
## So 1 means integer scaling is enabled and 0 disabled
func _ready() -> void:
	super._ready()
	button_pressed = get_tree().root.content_scale_stretch == 1

@warning_ignore("int_as_enum_without_cast")
func on_setting_changed(enabled: bool) -> void:
	get_tree().root.content_scale_stretch = int(enabled)
	IndieBlueprintSettingsManager.update_graphics_section(IndieBlueprintGameSettings.IntegerScalingSetting, get_tree().root.content_scale_stretch)
