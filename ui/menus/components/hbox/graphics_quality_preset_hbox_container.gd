class_name GraphicsQualitySetting extends VBoxContainer

var graphics_quality_label: Label = Label.new()
var quality_preset_buttons: Dictionary = {}
var quality_preset_button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	graphics_quality_label.name = "GraphicsQualityLabel"
	graphics_quality_label.text = tr(TranslationKeys.GraphicsQualityTranslationKey)
	
	add_child(graphics_quality_label)

	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_theme_constant_override("separation", 15)
	
	create_graphic_quality_preset_buttons()


func create_graphic_quality_preset_buttons() -> void:
	var hbox_container: HBoxContainer = HBoxContainer.new()
	hbox_container.set_anchors_preset(PRESET_TOP_WIDE)
	hbox_container.size_flags_horizontal = Control.SIZE_FILL
	add_child(hbox_container)
	
	quality_preset_button_group.pressed.connect(on_quality_button_pressed)
	
	for quality_preset in HardwareDetector.graphics_quality_presets:
		var button: Button = Button.new()
		button.set_meta("quality_preset", quality_preset)
		button.text = tr(TranslationKeys.QualityPresetKeys[quality_preset])
		button.name = button.text
		button.button_group = quality_preset_button_group
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		button.button_pressed = int(quality_preset) == int(SettingsManager.get_graphics_section("quality_preset"))
		
		quality_preset_buttons[quality_preset] = button
		
		hbox_container.add_child(button)
		

func on_quality_button_pressed(quality_preset_button: BaseButton) -> void:
	SettingsManager.update_graphics_section("quality_preset", quality_preset_button.get_meta("quality_preset"))
	SettingsManager.save_settings()
