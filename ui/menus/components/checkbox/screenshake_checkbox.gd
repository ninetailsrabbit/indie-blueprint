class_name ScreenShakeCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = SettingsManager.get_accessibility_section(GameSettings.ScreenShakeSetting)
	toggled.connect(on_screen_shake_changed)


func on_screen_shake_changed(enabled: bool) -> void:	
	SettingsManager.update_accessibility_section(GameSettings.ScreenShakeSetting, enabled)
