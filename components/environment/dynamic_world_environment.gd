class_name DynamicWorldEnvironment extends WorldEnvironment

const GroupName: StringName = &"dynamic-environment-world"


func _enter_tree() -> void:
	add_to_group(GroupName)
	
	
func _ready() -> void:
	environment.adjustment_enabled = true
	
	IndieBlueprintSettingsManager.apply_graphics_on_environment(self)
	IndieBlueprintSettingsManager.updated_setting_section.connect(on_updated_setting_section)
	
	
func on_updated_setting_section(section: String, key: String, value: Variant) -> void:
	if section == IndieBlueprintGameSettings.GraphicsSection \
		and key == IndieBlueprintGameSettings.QualityPresetSetting:
			
		IndieBlueprintSettingsManager.apply_graphics_on_environment(self, value)
		
	elif section == IndieBlueprintGameSettings.AccessibilitySection:
		match key:
			IndieBlueprintGameSettings.ScreenBrightnessSetting:
				environment.adjustment_brightness = value
			IndieBlueprintGameSettings.ScreenContrastSetting:
				environment.adjustment_contrast = value
			IndieBlueprintGameSettings.ScreenSaturationSetting:
				environment.adjustment_saturation = value
				
