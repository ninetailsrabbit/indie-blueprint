extends Node

signal reset_to_default_settings
signal created_settings
signal loaded_settings
signal updated_setting_section(section: String, key: String, value: Variant)

const KeybindingSeparator: String = "|"
const InputEventSeparator: String = ":"
const FileFormat: String = "ini" #  ini or cfg

var settings_file_path: String = OS.get_user_data_dir() + "/settings.%s" % FileFormat
var config_file_api: ConfigFile = ConfigFile.new()
var include_ui_keybindings: bool = false
var automatic: bool = true


func _ready() -> void:
	print(settings_file_path)
	if automatic:
		prepare_settings()


#region Generic
func save_settings(path: String = settings_file_path) -> void:
	config_file_api.save(path)


func reset_to_factory_settings(path: String = settings_file_path) -> void:
	if FileAccess.file_exists(path):
		config_file_api.clear()
		DirAccess.remove_absolute(path)
		
	create_settings(path)
	load_settings(path)
	
	reset_to_default_settings.emit()


func prepare_settings() -> void:
	if(FileAccess.file_exists(settings_file_path)):
		load_settings()
	else:
		create_settings()


func load_settings(path: String = settings_file_path) -> void:
	var error = config_file_api.load(path)
	
	if error != OK:
		push_error("SettingsManager: An error %d ocurred trying to load the settings from path %s " % [error, path])

	load_audio()
	load_graphics()
	load_localization()
	load_keybindings()
	
	loaded_settings.emit()
#endregion


#region Creation
func create_settings(path: String = settings_file_path) -> void:
	create_audio_section()
	create_graphics_section()
	create_accessibility_section()
	create_localization_section()
	create_analytics_section()
	create_keybindings_section()
	
	save_settings(path)
	
	created_settings.emit()

func create_audio_section() -> void:
	for bus: String in AudioManager.available_buses:
		update_audio_section(bus, AudioManager.get_default_volume_for_bus(bus))
		
	update_audio_section(GameSettings.MutedAudioSetting, false)


func create_graphics_section() -> void:
	var quality_preset = HardwareDetector.auto_discover_graphics_quality()
		
	update_graphics_section(GameSettings.FpsCounterSetting, false)
	update_graphics_section(GameSettings.MaxFpsSetting, 0)
	update_graphics_section(GameSettings.WindowDisplaySetting, DisplayServer.window_get_mode())
	update_graphics_section(GameSettings.WindowResolutionSetting, DisplayServer.window_get_size())
	update_graphics_section(GameSettings.VsyncSetting, DisplayServer.window_get_vsync_mode())
	update_graphics_section(GameSettings.QualityPresetSetting, quality_preset)
	

func create_accessibility_section() -> void:
	update_accessibility_section(GameSettings.MouseSensivitySetting, 3.0)
	update_accessibility_section(GameSettings.ControllerVibrationSetting, true)
	update_accessibility_section(GameSettings.ScreenBrightnessSetting, 1.0)
	update_accessibility_section(GameSettings.PhotosensitivitySetting, false)
	update_accessibility_section(GameSettings.ScreenShakeSetting, true)
	update_accessibility_section(GameSettings.DaltonismSetting, WindowManager.DaltonismTypes.No)


func create_localization_section() -> void:
	update_localization_section(GameSettings.CurrentLanguageSetting, TranslationServer.get_locale())
	update_localization_section(GameSettings.VoicesLanguageSetting, TranslationServer.get_locale())
	update_localization_section(GameSettings.SubtitlesEnabledSetting, false)
	update_localization_section(GameSettings.SubtitlesLanguageSetting, TranslationServer.get_locale())


func create_analytics_section() -> void:
	update_analytics_section(GameSettings.AllowTelemetrySetting, false)


func create_keybindings_section() -> void:
	var keybindings: Dictionary = {}
	var whitespace_regex = RegEx.new()
	whitespace_regex.compile(r"\s+")
	
	for action: StringName in _get_input_map_actions():
		var keybindings_events: Array[String] = []
		
		for input_event: InputEvent in InputHelper.get_all_inputs_for_action(action):
			
			if input_event is InputEventKey:
				keybindings_events.append("InputEventKey:%s" %  StringHelper.remove_whitespaces(InputHelper.readable_key(input_event)))
				
			if input_event is InputEventMouseButton:
				var mouse_button_text: String = ""
				
				match(input_event.button_index):
					MOUSE_BUTTON_LEFT:
						mouse_button_text = "LMB"
					MOUSE_BUTTON_RIGHT:
						mouse_button_text = "RMB"
					MOUSE_BUTTON_MIDDLE:
						mouse_button_text = "MMB"
					MOUSE_BUTTON_WHEEL_DOWN:
						mouse_button_text = "WheelDown"
					MOUSE_BUTTON_WHEEL_UP:
						mouse_button_text = "WheelUp"
					MOUSE_BUTTON_WHEEL_RIGHT:
						mouse_button_text = "WheelRight"
					MOUSE_BUTTON_WHEEL_LEFT:
						mouse_button_text = "WheelLeft"
						
				keybindings_events.append("InputEventMouseButton%s%d%s%s" % [InputEventSeparator, input_event.button_index, InputEventSeparator, mouse_button_text])
			
			if input_event is InputEventJoypadMotion:
				var joypadAxis: String = ""
				
				match(input_event.axis):
					JOY_AXIS_LEFT_X:
						joypadAxis = "Left Stick %s" % "Left" if input_event.axis_value < 0 else "Right"
					JOY_AXIS_LEFT_Y:
						joypadAxis = "Left Stick %s" % "Up" if input_event.axis_value < 0 else "Down"
					JOY_AXIS_RIGHT_X:
						joypadAxis = "Right Stick %s" % "Left" if input_event.axis_value < 0 else "Right"
					JOY_AXIS_RIGHT_Y:
						joypadAxis = "Right Stick %s" % "Up" if input_event.axis_value < 0 else "Down"
					JOY_AXIS_TRIGGER_LEFT:
						joypadAxis = "Left Trigger"
					JOY_AXIS_TRIGGER_RIGHT:
						joypadAxis = "Right trigger"
				
				keybindings_events.append("InputEventJoypadMotion%s%d%s%d%s%s" % [InputEventSeparator, input_event.axis, InputEventSeparator, input_event.axis_value, InputEventSeparator, joypadAxis])
				
			if input_event is InputEventJoypadButton:
				var joypadButton: String = ""
				
				if(GamepadControllerManager.current_controller_is_xbox() or GamepadControllerManager.current_controller_is_generic()):
					joypadButton = "%s Button" % GamepadControllerManager.XboxButtonLabels[input_event.button_index]
				
				elif GamepadControllerManager.current_controller_is_switch() or GamepadControllerManager.current_controller_is_switch_joycon():
					joypadButton = "%s Button" % GamepadControllerManager.SwitchButtonLabels[input_event.button_index]
				
				elif  GamepadControllerManager.current_controller_is_playstation():
					joypadButton = "%s Button" % GamepadControllerManager.PlaystationButtonLabels[input_event.button_index]
					
				keybindings_events.append("InputEventJoypadButton%s%d%s%s" % [InputEventSeparator, input_event.button_index, InputEventSeparator, joypadButton])
				
				
		keybindings[action] = KeybindingSeparator.join(keybindings_events)
		update_keybindings_section(action, keybindings[action])
		
#endregion

#region Load
func load_audio() -> void:
	var muted_buses: bool = get_audio_section(GameSettings.MutedAudioSetting)
	
	for bus in config_file_api.get_section_keys(GameSettings.AudioSection):
		if(bus in AudioManager.available_buses):
			AudioManager.change_volume(bus, get_audio_section(bus))
			AudioManager.mute_bus(bus, muted_buses)
		

func load_graphics() -> void:
	for section_key: String in config_file_api.get_section_keys(GameSettings.GraphicsSection):
		var config_value = get_graphics_section(section_key)
		
		match section_key:
			GameSettings.MaxFpsSetting:
				Engine.max_fps = config_value
			GameSettings.WindowDisplaySetting:
				DisplayServer.window_set_mode(config_value)
			GameSettings.WindowResolutionSetting:
				DisplayServer.window_set_size(config_value)
			GameSettings.VsyncSetting:
				DisplayServer.window_set_vsync_mode(config_value)
	
		updated_setting_section.emit(GameSettings.GraphicsSection, section_key, config_value)
		


func load_localization() -> void:
	for section_key: String in config_file_api.get_section_keys(GameSettings.LocalizationSection):
		var config_value = get_localization_section(section_key)
		
		match section_key:
			GameSettings.CurrentLanguageSetting:
				TranslationServer.set_locale(config_value)
				
		updated_setting_section.emit(GameSettings.LocalizationSection, section_key, config_value)
		

func load_keybindings() -> void:
	for action: String in config_file_api.get_section_keys(GameSettings.KeybindingsSection):
		var keybinding: String = get_keybindings_section(action)
		
		InputMap.action_erase_events(action)
		
		if keybinding.contains(KeybindingSeparator):
			for value: String in keybinding.split(KeybindingSeparator):
				_add_keybinding_event(action, value.split(InputEventSeparator))
		else:
			_add_keybinding_event(action, keybinding.split(InputEventSeparator))
	
#endregion

#region Section Getters
func get_audio_section(key: String):
	return config_file_api.get_value(GameSettings.AudioSection, key)


func get_keybindings_section(key: String):
	return config_file_api.get_value(GameSettings.KeybindingsSection, key)


func get_graphics_section(key: String):
	return config_file_api.get_value(GameSettings.GraphicsSection, key)


func get_accessibility_section(key: String):
	return config_file_api.get_value(GameSettings.AccessibilitySection, key)


func get_controls_section(key: String):
	return config_file_api.get_value(GameSettings.ControlsSection, key)


func get_localization_section(key: String):
	return config_file_api.get_value(GameSettings.LocalizationSection, key)
	
func get_analytics_section(key: String):
	return config_file_api.get_value(GameSettings.AnalyticsSection, key)

#endregion
	
#region Section updaters
func update_audio_section(key: String, value: Variant) -> void:
	config_file_api.set_value(GameSettings.AudioSection, key, value)
	updated_setting_section.emit(GameSettings.AudioSection, key, value)


func update_keybindings_section(key: String, value: Variant) -> void:
	config_file_api.set_value(GameSettings.KeybindingsSection, key, value)
	updated_setting_section.emit(GameSettings.KeybindingsSection, key, value)


func update_graphics_section(key: String, value: Variant) -> void:
	config_file_api.set_value(GameSettings.GraphicsSection, key, value)
	
	updated_setting_section.emit(GameSettings.GraphicsSection, key, value)

	
func update_accessibility_section(key: String, value: Variant) -> void:
	config_file_api.set_value(GameSettings.AccessibilitySection, key, value)
	
	updated_setting_section.emit(GameSettings.AccessibilitySection, key, value)
	

func update_controls_section(key: String, value: Variant) -> void:
	config_file_api.set_value(GameSettings.ControlsSection, key, value)
	
	updated_setting_section.emit(GameSettings.ControlsSection, key, value)
	

func update_analytics_section(key: String, value: Variant) -> void:
	config_file_api.set_value(GameSettings.AnalyticsSection, key, value)
	
	updated_setting_section.emit(GameSettings.AnalyticsSection, key, value)
	

func update_localization_section(key: String, value: Variant) -> void:
	config_file_api.set_value(GameSettings.LocalizationSection, key, value)

	updated_setting_section.emit(GameSettings.LocalizationSection, key, value)
	
#endregion

#region Private functions
func _add_keybinding_event(action: String, keybinding_type: Array[String] = []):
	var keybinding_modifiers_regex = RegEx.new()
	keybinding_modifiers_regex.compile(r"\b(Shift|Ctrl|Alt)\+\b")
	
	match keybinding_type[0]:
		"InputEventKey":
			var input_event_key = InputEventKey.new()
			input_event_key.keycode = OS.find_keycode_from_string(StringHelper.str_replace(keybinding_type[1].strip_edges(), keybinding_modifiers_regex, func(_text: String): return ""))
			input_event_key.alt_pressed = not StringHelper.case_insensitive_comparison(keybinding_type[1], "alt") and keybinding_type[1].containsn("alt")
			input_event_key.ctrl_pressed = not StringHelper.case_insensitive_comparison(keybinding_type[1], "ctrl") and keybinding_type[1].containsn("ctrl")
			input_event_key.shift_pressed = not StringHelper.case_insensitive_comparison(keybinding_type[1], "shift") and keybinding_type[1].containsn("shift")
			input_event_key.meta_pressed =  keybinding_type[1].containsn("meta")
			
			InputMap.action_add_event(action, input_event_key)
		"InputEventMouseButton":
			var input_event_mouse_button = InputEventMouseButton.new()
			input_event_mouse_button.button_index = int(keybinding_type[1])
			
			InputMap.action_add_event(action, input_event_mouse_button)
		"InputEventJoypadMotion":
			var input_event_joypad_motion = InputEventJoypadMotion.new()
			input_event_joypad_motion.axis = int(keybinding_type[1])
			input_event_joypad_motion.axis_value = float(keybinding_type[2])
			
			InputMap.action_add_event(action, input_event_joypad_motion)
		"InputEventJoypadButton":
			var input_event_joypad_button = InputEventJoypadButton.new()
			input_event_joypad_button.button_index = int(keybinding_type[1])
			
			InputMap.action_add_event(action, input_event_joypad_button)
	
	
func _get_input_map_actions() -> Array[StringName]:
	return InputMap.get_actions() if include_ui_keybindings else InputMap.get_actions().filter(func(action): return !action.contains("ui_"))
#endregion
