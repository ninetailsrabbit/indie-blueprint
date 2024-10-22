class_name ScreenBrightnessSlider extends HSlider


func _enter_tree() -> void:
	name = "ScreenBrightnessSlider"
	
	min_value = 0.0
	max_value = 1.0
	step = 0.01
	
	drag_ended.connect(on_brightness_changed)


func _ready() -> void:
	value = SettingsManager.get_accessibility_section(GameSettings.ScreenBrightnessSetting)
		


func on_brightness_changed(brightness: float) -> void:
	SettingsManager.update_accessibility_section(GameSettings.ScreenBrightnessSetting, brightness)
