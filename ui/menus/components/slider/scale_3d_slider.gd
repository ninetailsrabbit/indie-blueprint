class_name Scale3DSlider extends HSlider


func _enter_tree() -> void:
	min_value = 1.0
	max_value = 5.0
	step = 1.0
	tick_count = ceil(max_value / min_value)
	ticks_on_borders = true
	
	value_changed.connect(on_scale_value_changed)


func _ready() -> void:
	scale_value_to_slider_value(SettingsManager.get_graphics_section(GameSettings.Scaling3DValue))


func scale_value_to_slider_value(scale_3d_value: float) -> void:
	if scale_3d_value == 1.0:
		#scale_3d_label.text = str("100%")
		value = 5.0
	elif scale_3d_value == 0.77:
		#scale_3d_label.text = str("77%")
		value = 4.0
	elif scale_3d_value == 0.67:
		#scale_3d_label.text = str("67%")
		value = 3.0
	elif scale_3d_value == 0.59:
		#scale_3d_label.text = str("59%")
		value = 2.0
	elif scale_3d_value == 0.5:
		#scale_3d_label.text = str("50%")
		value = 1.0
	else:
		value = max_value
	

func slider_value_to_scale_value(slider_value: float) -> float:
	var new_value: float = 1.0
	
	if slider_value == 1.0:
		new_value = 0.5 # 50 %
	elif slider_value == 2.0:
		new_value = 0.59 # 59 %
	elif slider_value == 3.0:
		new_value = 0.67 # 67 %
	elif slider_value == 4.0:
		new_value = 0.77 # 77 %
	elif slider_value == 5.0:
		new_value = 1.0 # 100 %
	else:
		new_value = get_viewport().scaling_3d_scale
		
	return new_value 


func on_scale_value_changed(new_value: float) -> void:
	SettingsManager.update_graphics_section(GameSettings.Scaling3DValue, slider_value_to_scale_value(new_value))
