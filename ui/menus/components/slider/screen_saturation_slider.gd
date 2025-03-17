class_name ScreenSaturationSlider extends HSlider

@export var saturation_value_label: Label


func _enter_tree() -> void:
	name = "ScreenSaturationSlider"
	
	min_value = 0.01
	max_value = 8.0
	step = 0.01
	
	if saturation_value_label:
		value_changed.connect(on_value_changed)
	
	drag_ended.connect(on_saturation_changed)


func _ready() -> void:
	value = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.ScreenSaturationSetting)
	update_saturation_value_label(value)


func on_saturation_changed(saturation_changed: bool) -> void:
	if saturation_changed:
		IndieBlueprintSettingsManager.update_accessibility_section(IndieBlueprintGameSettings.ScreenSaturationSetting, value)


func update_saturation_value_label(new_value: float) -> void:
	if saturation_value_label:
		saturation_value_label.text = str(new_value)
	
	
func on_value_changed(new_value: float) -> void:
	update_saturation_value_label(new_value)
