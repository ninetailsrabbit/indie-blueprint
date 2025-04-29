class_name CameraFovSlider extends HSlider

@export var value_label: Label


func _enter_tree() -> void:
	min_value = 1
	max_value = 179
	step = 1
	#tick_count = ceili(max_value / min_value)
	#ticks_on_borders = true
	
	if value_label:
		value_changed.connect(on_value_changed)
		
	drag_ended.connect(on_camera_fov_changed)


func _ready() -> void:
	value = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.CameraFovSetting)
		
	update_fov_value_label(value)
		
	
func update_fov_value_label(new_value: float) -> void:
	if value_label:
		value_label.text = str(ceili(new_value))
		

func on_camera_fov_changed(camera_fov_changed: bool) -> void:
	if camera_fov_changed:
		IndieBlueprintSettingsManager.update_accessibility_section(IndieBlueprintGameSettings.CameraFovSetting, value)


func on_value_changed(new_value: float) -> void:
	update_fov_value_label(new_value)
