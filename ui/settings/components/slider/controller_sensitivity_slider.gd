class_name ControllerSensitivitySlider extends HSlider


func _enter_tree() -> void:
	min_value = 0.5
	max_value = 20
	step = 0.5
	tick_count = ceil(max_value / min_value)
	ticks_on_borders = true
	
	drag_ended.connect(on_sensitivity_changed)


func _ready() -> void:
	value = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.ControllerSensivitySetting)
		

func on_sensitivity_changed(sensitivity_changed: bool) -> void:
	if sensitivity_changed:
		IndieBlueprintSettingsManager.update_accessibility_section(IndieBlueprintGameSettings.ControllerSensivitySetting, value)
