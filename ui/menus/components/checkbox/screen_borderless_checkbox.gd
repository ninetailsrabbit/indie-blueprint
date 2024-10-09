class_name ScreenBorderlessCheckbox extends CheckBox



func _ready() -> void:
	button_pressed = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	toggled.connect(on_screen_borderless_changed)


func on_screen_borderless_changed(enabled: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, enabled)
	SettingsManager.update_graphics_section(GameSettings.WindowDisplayBorderlessSetting, enabled)
