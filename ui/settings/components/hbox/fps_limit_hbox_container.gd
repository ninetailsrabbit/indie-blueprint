class_name FpsLimitHboxContainer extends HBoxContainer

## The range of available frame per second limits, this option should only be enabled when vsync it's off
@export var fps_limits: GameSetting

var fps_limit_button_group: ButtonGroup = ButtonGroup.new()


func _enter_tree() -> void:
	if fps_limits == null:
		if IndieBlueprintSettingsManager.active_settings.has(IndieBlueprintGameSettings.FpsLimitsSetting):
			fps_limits = IndieBlueprintSettingsManager.active_settings[IndieBlueprintGameSettings.FpsLimitsSetting]
	
	assert(fps_limits.field_type == TYPE_ARRAY and fps_limits.value().size() > 0, "FpsLimitsHboxContainer: The game setting resource does not contain a value of type Array[int]")


func _ready() -> void:
	create_fps_limit_buttons()


func create_fps_limit_buttons() -> void:
	fps_limit_button_group.pressed.connect(on_fps_limit_button_pressed)
	
	for fps_limit: int in fps_limits.value():
		var button: Button = Button.new()
		button.text = str(fps_limit)
		button.name = str(fps_limit)
		button.button_group = fps_limit_button_group
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.button_pressed = Engine.max_fps == fps_limit
				
		add_child(button)
		

func on_fps_limit_button_pressed(fps_limit_button: BaseButton) -> void:
	var limit = fps_limit_button.name.strip_edges().to_int()
	Engine.max_fps = limit
	
	IndieBlueprintSettingsManager.update_graphics_section(IndieBlueprintGameSettings.MaxFpsSetting, limit)
