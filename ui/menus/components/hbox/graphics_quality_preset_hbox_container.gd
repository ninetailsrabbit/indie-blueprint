class_name GraphicsQualitySetting extends HBoxContainer

var quality_preset_buttons: Dictionary = {}
var quality_preset_button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	create_graphic_quality_preset_buttons()


func create_graphic_quality_preset_buttons() -> void:

	quality_preset_button_group.pressed.connect(on_quality_button_pressed)
	
	for quality_preset in HardwareDetector.graphics_quality_presets:
		var button: Button = Button.new()
		button.set_meta(GameSettings.QualityPresetSetting, quality_preset)
		button.text = tr(TranslationKeys.QualityPresetKeys[quality_preset])
		button.name = button.text
		button.button_group = quality_preset_button_group
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		button.button_pressed = int(quality_preset) == int(SettingsManager.get_graphics_section(GameSettings.QualityPresetSetting))
		
		quality_preset_buttons[quality_preset] = button
		
		add_child(button)


func on_quality_button_pressed(quality_preset_button: BaseButton) -> void:
	SettingsManager.update_graphics_section(GameSettings.QualityPresetSetting, quality_preset_button.get_meta(GameSettings.QualityPresetSetting))
