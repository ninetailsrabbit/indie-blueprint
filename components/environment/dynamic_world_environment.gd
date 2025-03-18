class_name DynamicWorldEnvironment extends WorldEnvironment



func _ready() -> void:
	IndieBlueprintSettingsManager.apply_graphics_on_environment(self)
	IndieBlueprintSettingsManager.updated_setting_section.connect(on_updated_setting_section)
	
	
func on_updated_setting_section(section: String, key: String, value: Variant) -> void:
	if section == IndieBlueprintGameSettings.GraphicsSection and key == IndieBlueprintGameSettings.QualityPresetSetting:
		IndieBlueprintSettingsManager.apply_graphics_on_environment(self, value)
		
