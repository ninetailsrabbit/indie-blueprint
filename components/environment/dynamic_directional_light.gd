class_name DynamicDirectionalLight3D extends DirectionalLight3D

const GroupName: StringName = &"dynamic-environment-light"


func _enter_tree() -> void:
	add_to_group(GroupName)
	

func _ready() -> void:
	IndieBlueprintSettingsManager.apply_graphics_on_directional_light(
		self, 
		IndieBlueprintSettingsManager.get_graphics_section(IndieBlueprintGameSettings.QualityPresetSetting)
		)
		
	IndieBlueprintSettingsManager.updated_setting_section.connect(on_updated_setting_section)
	
	
func on_updated_setting_section(section: String, key: String, value: Variant) -> void:
	if section == IndieBlueprintGameSettings.GraphicsSection and key == IndieBlueprintGameSettings.QualityPresetSetting:
		IndieBlueprintSettingsManager.apply_graphics_on_directional_light(self, value)
		
