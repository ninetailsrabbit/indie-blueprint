class_name PhotosensitiveCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = SettingsManager.get_accessibility_section(GameSettings.PhotosensitivitySetting)
	toggled.connect(on_photosensitive_changed)


func on_photosensitive_changed(enabled: bool) -> void:	
	SettingsManager.update_accessibility_section(GameSettings.PhotosensitivitySetting, enabled)
