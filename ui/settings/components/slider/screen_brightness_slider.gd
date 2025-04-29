class_name ScreenBrightnessSlider extends HSlider

@export var brightness_value_label: Label


func _enter_tree() -> void:
	name = "ScreenBrightnessSlider"
	
	min_value = 0.01
	max_value = 8.0
	step = 0.01
	
	if brightness_value_label:
		value_changed.connect(on_value_changed)
	
	drag_ended.connect(on_brightness_changed)


func _ready() -> void:
	value = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.ScreenBrightnessSetting)
	update_brightness_value_label(value)


func on_brightness_changed(brightness_changed: bool) -> void:
	if brightness_changed:
		IndieBlueprintSettingsManager.update_accessibility_section(IndieBlueprintGameSettings.ScreenBrightnessSetting, value)


func update_brightness_value_label(new_value: float) -> void:
	if brightness_value_label:
		brightness_value_label.text = str(new_value)
	
	
func on_value_changed(new_value: float) -> void:
	update_brightness_value_label(new_value)
