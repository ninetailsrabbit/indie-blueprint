class_name SettingHSlider extends HSlider

@export var setting: GameSetting


func _enter_tree() -> void:
	assert(setting != null, "SettingHSlider: The %s hslider does not have a GameSetting resource linked" % name)
	assert(setting.field_type in [TYPE_INT, TYPE_FLOAT], "SettingHSlider: The '%s hslider' contains a setting '%s' that is not a int|float type" % [name, setting.key])

	var minimum_value
	var maximum_value
	
	if setting.field_type == TYPE_FLOAT:
		minimum_value = setting.min_float_value
		maximum_value = setting.max_float_value
	elif setting.field_type == TYPE_INT:
		minimum_value = setting.min_int_value
		maximum_value = setting.max_int_value
		
	min_value = minimum_value
	max_value = maximum_value

	tick_count = ceil(max_value / min_value)
	ticks_on_borders = true
	

func _ready() -> void:
	value = IndieBlueprintSettingsManager.get_section(setting.section, setting.key)
	drag_ended.connect(on_setting_changed)
	

func on_setting_changed(new_value_changed: bool) -> void:
	if new_value_changed:
		IndieBlueprintSettingsManager.update_setting_section(setting.section, setting.key, value)
