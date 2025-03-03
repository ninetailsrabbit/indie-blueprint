class_name ScreenShakeCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.ScreenShakeSetting)
	toggled.connect(on_screen_shake_changed)


func on_screen_shake_changed(enabled: bool) -> void:	
	IndieBlueprintSettingsManager.update_accessibility_section(IndieBlueprintGameSettings.ScreenShakeSetting, enabled)
