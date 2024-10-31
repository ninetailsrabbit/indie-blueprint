extends Node

signal reset_to_default_settings
signal created_settings
signal loaded_settings
signal removed_setting_file
signal updated_setting_section(section: String, key: String, value: Variant)

const KeybindingSeparator: String = "|"
const InputEventSeparator: String = ":"
const FileFormat: String = "ini" #  ini or cfg

var settings_file_path: String = OS.get_user_data_dir() + "/settings.%s" % FileFormat
var config_file_api: ConfigFile = ConfigFile.new()
var use_encription: bool = false
var include_ui_keybindings: bool = false
var load_on_start: bool = true


func _enter_tree() -> void:
	updated_setting_section.connect(on_updated_setting_section)
	
	
func _ready() -> void:
	if load_on_start:
		prepare_settings()


#region Generic
func save_settings(path: String = settings_file_path) -> void:
	var error: Error = config_file_api.save_encrypted_pass(path, encription_key()) if use_encription else config_file_api.save(path)
	
	if error != OK:
		push_error("SettingsManager: An error %d ocurred trying to save the settings on file %s " % [error_string(error), path])
		

func reset_to_factory_settings(path: String = settings_file_path) -> void:
	config_file_api.clear()
	
	remove_settings_file(path)
	create_settings(path)
	load_settings(path)
	
	reset_to_default_settings.emit()


func prepare_settings() -> void:
	if(FileAccess.file_exists(settings_file_path)):
		load_settings()
	else:
		create_settings()


func load_settings(path: String = settings_file_path) -> void:
	var error: Error = config_file_api.load_encrypted_pass(path, encription_key()) if use_encription else config_file_api.load(path) 
	
	if error != OK:
		push_error("SettingsManager: An error %d ocurred trying to load the settings from path %s " % [error_string(error), path])
		return
		
	load_audio()
	load_graphics()
	load_localization()
	load_keybindings()
	
	loaded_settings.emit()


func remove_settings_file(path: String = settings_file_path) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		
	removed_setting_file.emit()
	
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
	
	var buses_are_muted: bool = GameSettings.DefaultSettings[GameSettings.MutedAudioSetting]
	update_audio_section(GameSettings.MutedAudioSetting, buses_are_muted)
	
	if(buses_are_muted):
		AudioManager.mute_all_buses()
	else:
		AudioManager.unmute_all_buses()
		

func create_graphics_section() -> void:
	update_graphics_section(GameSettings.FpsCounterSetting, GameSettings.DefaultSettings[GameSettings.FpsCounterSetting])
	update_graphics_section(GameSettings.MaxFpsSetting, GameSettings.DefaultSettings[GameSettings.MaxFpsSetting])
	update_graphics_section(GameSettings.WindowDisplaySetting, GameSettings.DefaultSettings[GameSettings.WindowDisplaySetting])
	update_graphics_section(GameSettings.WindowDisplayBorderlessSetting,  GameSettings.DefaultSettings[GameSettings.WindowDisplayBorderlessSetting])
	update_graphics_section(GameSettings.WindowResolutionSetting, GameSettings.DefaultSettings[GameSettings.WindowResolutionSetting])
	update_graphics_section(GameSettings.VsyncSetting, GameSettings.DefaultSettings[GameSettings.VsyncSetting])
	update_graphics_section(GameSettings.QualityPresetSetting, GameSettings.DefaultSettings[GameSettings.QualityPresetSetting])
	

func create_accessibility_section() -> void:
	update_accessibility_section(GameSettings.MouseSensivitySetting, GameSettings.DefaultSettings[GameSettings.MouseSensivitySetting])
	update_accessibility_section(GameSettings.ReversedMouseSetting, GameSettings.DefaultSettings[GameSettings.ReversedMouseSetting])
	update_accessibility_section(GameSettings.ControllerVibrationSetting, GameSettings.DefaultSettings[GameSettings.ControllerVibrationSetting])
	update_accessibility_section(GameSettings.ScreenBrightnessSetting, GameSettings.DefaultSettings[GameSettings.ScreenBrightnessSetting])
	update_accessibility_section(GameSettings.PhotosensitivitySetting, GameSettings.DefaultSettings[GameSettings.PhotosensitivitySetting])
	update_accessibility_section(GameSettings.ScreenShakeSetting, GameSettings.DefaultSettings[GameSettings.ScreenShakeSetting])
	update_accessibility_section(GameSettings.DaltonismSetting, GameSettings.DefaultSettings[GameSettings.DaltonismSetting])


func create_localization_section() -> void:
	update_localization_section(GameSettings.CurrentLanguageSetting, GameSettings.DefaultSettings[GameSettings.CurrentLanguageSetting])
	update_localization_section(GameSettings.VoicesLanguageSetting, GameSettings.DefaultSettings[GameSettings.VoicesLanguageSetting])
	update_localization_section(GameSettings.SubtitlesLanguageSetting, GameSettings.DefaultSettings[GameSettings.SubtitlesLanguageSetting])
	update_localization_section(GameSettings.SubtitlesEnabledSetting, GameSettings.DefaultSettings[GameSettings.SubtitlesEnabledSetting])


func create_analytics_section() -> void:
	update_analytics_section(GameSettings.AllowTelemetrySetting, GameSettings.DefaultSettings[GameSettings.AllowTelemetrySetting])


func create_keybindings_section() -> void:
	_get_input_map_actions().map(create_keybinding_events_for_action)
	update_keybindings_section(GameSettings.DefaultInputMapActionsSetting, GameSettings.DefaultSettings[GameSettings.DefaultInputMapActionsSetting])
#endregion


func create_keybinding_events_for_action(action: StringName) -> Array[String]:
	var keybinding_events: Array[String] = []
	var all_inputs_for_action: Array[InputEvent] = InputHelper.get_all_inputs_for_action(action)
	## We save the default input map actions to allow players reset to factory default
	GameSettings.DefaultSettings[GameSettings.DefaultInputMapActionsSetting][action] = all_inputs_for_action
	
	for input_event: InputEvent in all_inputs_for_action:
		if input_event is InputEventKey:
			keybinding_events.append("InputEventKey:%s" %  StringHelper.remove_whitespaces(InputHelper.readable_key(input_event)))
			
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
					
			keybinding_events.append("InputEventMouseButton%s%d%s%s" % [InputEventSeparator, input_event.button_index, InputEventSeparator, mouse_button_text])
		
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
			
			keybinding_events.append("InputEventJoypadMotion%s%d%s%d%s%s" % [InputEventSeparator, input_event.axis, InputEventSeparator, input_event.axis_value, InputEventSeparator, joypadAxis])
			
		if input_event is InputEventJoypadButton:
			var joypadButton: String = ""
			
			if(GamepadControllerManager.current_controller_is_xbox() or GamepadControllerManager.current_controller_is_generic()):
				joypadButton = "%s Button" % GamepadControllerManager.XboxButtonLabels[input_event.button_index]
			
			elif GamepadControllerManager.current_controller_is_switch() or GamepadControllerManager.current_controller_is_switch_joycon():
				joypadButton = "%s Button" % GamepadControllerManager.SwitchButtonLabels[input_event.button_index]
			
			elif  GamepadControllerManager.current_controller_is_playstation():
				joypadButton = "%s Button" % GamepadControllerManager.PlaystationButtonLabels[input_event.button_index]
				
			keybinding_events.append("InputEventJoypadButton%s%d%s%s" % [InputEventSeparator, input_event.button_index, InputEventSeparator, joypadButton])
	
	
	update_keybindings_section(action, KeybindingSeparator.join(keybinding_events))
	
	return keybinding_events


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
			GameSettings.WindowDisplayBorderlessSetting:
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, bool(config_value))
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
	GameSettings.DefaultSettings[GameSettings.DefaultInputMapActionsSetting] = get_keybindings_section(GameSettings.DefaultInputMapActionsSetting)
	
	for action: String in config_file_api.get_section_keys(GameSettings.KeybindingsSection):
		if action in [GameSettings.DefaultInputMapActionsSetting]:
			continue
			
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
	
#region Environment
func apply_graphics_on_directional_light(directional_light: DirectionalLight3D, quality_preset: HardwareDetector.QualityPreset = HardwareDetector.QualityPreset.Medium) -> void:
	var preset: HardwareDetector.GraphicQualityPreset = HardwareDetector.graphics_quality_presets[quality_preset]
	
	for quality: HardwareDetector.GraphicQualityDisplay in preset.quality:
		match quality.project_setting:
			"shadow_atlas":
				match quality_preset:
					HardwareDetector.QualityPreset.Low:
						directional_light.shadow_bias = 0.03
					HardwareDetector.QualityPreset.Medium:
						directional_light.shadow_bias = 0.02
					HardwareDetector.QualityPreset.High:
						directional_light.shadow_bias = 0.01
					HardwareDetector.QualityPreset.Ultra:
						directional_light.shadow_bias = 0.005


@warning_ignore("int_as_enum_without_cast")
func apply_graphics_on_environment(world_environment: WorldEnvironment, quality_preset: HardwareDetector.QualityPreset = HardwareDetector.QualityPreset.Medium) -> void:
	var viewport: Viewport = world_environment.get_viewport()
	var preset: HardwareDetector.GraphicQualityPreset = HardwareDetector.graphics_quality_presets[quality_preset]
	
	for quality: HardwareDetector.GraphicQualityDisplay in preset.quality:
		match quality.project_setting:
			"environment/glow_enabled":
				world_environment.environment.glow_enabled = bool(quality.enabled)
			"environment/ssao_enabled":
				world_environment.environment.ssao_enabled = bool(quality.enabled)
				
				if world_environment.environment.ssao_enabled:
					match quality_preset:
						HardwareDetector.QualityPreset.Low:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
						HardwareDetector.QualityPreset.Medium:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
						HardwareDetector.QualityPreset.High:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
						HardwareDetector.QualityPreset.Ultra:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
			"environment/ss_reflections_enabled":
				world_environment.environment.ssr_enabled = bool(quality.enabled)
				
				if world_environment.environment.ssr_enabled:
					match quality_preset:
						HardwareDetector.QualityPreset.Low:
							world_environment.environment.ssr_max_steps = 8
						HardwareDetector.QualityPreset.Medium:
							world_environment.environment.ssr_max_steps = 32
						HardwareDetector.QualityPreset.High:
							world_environment.environment.ssr_max_steps = 56
						HardwareDetector.QualityPreset.Ultra:
							world_environment.environment.ssr_max_steps = 56
			"environment/sdfgi_enabled":
				world_environment.environment.sdfgi_enabled = bool(quality.enabled)
				
				if world_environment.environment.sdfgi_enabled:
					match quality_preset:
						HardwareDetector.QualityPreset.Low:
							RenderingServer.gi_set_use_half_resolution(true)
						HardwareDetector.QualityPreset.Medium:
							RenderingServer.gi_set_use_half_resolution(true)
						HardwareDetector.QualityPreset.High:
							RenderingServer.gi_set_use_half_resolution(false)
						HardwareDetector.QualityPreset.Ultra:
							RenderingServer.gi_set_use_half_resolution(false)
			"environment/ssil_enabled":
				world_environment.environment.ssil_enabled = bool(quality.enabled)
			"rendering/anti_aliasing/quality/msaa_3d":
				viewport.msaa_3d = quality.enabled
			"shadow_atlas":
				RenderingServer.directional_shadow_atlas_set_size(quality.enabled, true)
				viewport.positional_shadow_atlas_size = quality.enabled
			"shadow_filter":
				RenderingServer.directional_soft_shadow_filter_set_quality(quality.enabled)
				RenderingServer.positional_soft_shadow_filter_set_quality(quality.enabled)
			"mesh_level_of_detail":
				viewport.mesh_lod_threshold = quality.enabled
#endregion
	

func _get_input_map_actions() -> Array[StringName]:
	return InputMap.get_actions() if include_ui_keybindings else InputMap.get_actions().filter(func(action): return !action.contains("ui_"))


func encription_key() -> StringName:
	return (&"%s%s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/description")]).sha256_text()

#region Signal callbacks
func on_updated_setting_section(_section: String, _key: String, _value: Variant) -> void:
	save_settings()
#endregion
