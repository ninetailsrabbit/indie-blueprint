class_name PhotosensitiveCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.PhotosensitivitySetting)
	toggled.connect(on_photosensitive_changed)


func on_photosensitive_changed(enabled: bool) -> void:	
	IndieBlueprintSettingsManager.update_accessibility_section(IndieBlueprintGameSettings.PhotosensitivitySetting, enabled)
