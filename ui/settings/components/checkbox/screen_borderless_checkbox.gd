class_name ScreenBorderlessCheckbox extends SettingCheckbox


func _ready() -> void:
	super._ready()
	button_pressed = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)


func on_setting_changed(enabled: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, enabled)
	IndieBlueprintSettingsManager.update_graphics_section(IndieBlueprintGameSettings.WindowDisplayBorderlessSetting, enabled)
