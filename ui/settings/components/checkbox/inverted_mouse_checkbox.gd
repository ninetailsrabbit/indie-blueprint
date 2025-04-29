class_name ReverseMouseCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.ReversedMouseSetting)
	toggled.connect(on_reverse_mouse_changed)


func on_reverse_mouse_changed(enabled: bool) -> void:	
	IndieBlueprintSettingsManager.update_accessibility_section(IndieBlueprintGameSettings.ReversedMouseSetting, enabled)
