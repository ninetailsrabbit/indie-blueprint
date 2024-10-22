class_name ReverseMouseCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = SettingsManager.get_accessibility_section(GameSettings.ReversedMouseSetting)
	toggled.connect(on_reverse_mouse_changed)


func on_reverse_mouse_changed(enabled: bool) -> void:	
	SettingsManager.update_accessibility_section(GameSettings.ReversedMouseSetting, enabled)
