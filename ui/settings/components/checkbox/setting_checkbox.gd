class_name SettingCheckbox extends CheckBox

@export var setting: GameSetting


func _enter_tree() -> void:
	assert(setting != null, "SettingCheckbox: The %s checkbox does not have a GameSetting resource linked" % name)
	assert(setting.field_type == TYPE_BOOL, "SettingCheckbox: The '%s checkbox' contains a setting '%s' that is not a boolean type" % [name, setting.key])


func _ready() -> void:
	button_pressed = IndieBlueprintSettingsManager.get_section(setting.section, setting.key)
	toggled.connect(on_setting_changed)


func on_setting_changed(enabled: bool) -> void:
	IndieBlueprintSettingsManager.update_setting_section(setting.section, setting.key, enabled)
