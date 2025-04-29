class_name ScreenContrastSlider extends HSlider

@export var contrast_value_label: Label


func _enter_tree() -> void:
	name = "ScreenContrastSlider"
	
	min_value = 0.01
	max_value = 8.0
	step = 0.01
	
	if contrast_value_label:
		value_changed.connect(on_value_changed)
	
	drag_ended.connect(on_contrast_changed)


func _ready() -> void:
	value = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.ScreenContrastSetting)
	update_contrast_value_label(value)


func on_contrast_changed(contrast_changed: bool) -> void:
	if contrast_changed:
		IndieBlueprintSettingsManager.update_accessibility_section(IndieBlueprintGameSettings.ScreenContrastSetting, value)


func update_contrast_value_label(new_value: float) -> void:
	if contrast_value_label:
		contrast_value_label.text = str(new_value)
	
	
func on_value_changed(new_value: float) -> void:
	update_contrast_value_label(new_value)
