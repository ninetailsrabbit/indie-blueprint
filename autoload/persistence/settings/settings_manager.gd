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


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()
		
		
func _enter_tree() -> void:
	updated_setting_section.connect(on_updated_setting_section)
	
	
func _ready() -> void:
	if load_on_start:
		prepare_settings()

#region Generic
func save_settings(path: String = settings_file_path) -> void:
	var error: Error = config_file_api.save_encrypted_pass(path, encription_key()) if use_encription else config_file_api.save(path)
	
	if error != OK:
		push_error("IndieBlueprintSettingsManager: An error %d ocurred trying to save the settings on file %s " % [error_string(error), path])
		

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
		push_error("IndieBlueprintSettingsManager: An error %d ocurred trying to load the settings from path %s " % [error_string(error), path])
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
	for bus: String in IndieBlueprintAudioManager.enumerate_available_buses():
		update_audio_section(bus, IndieBlueprintAudioManager.get_default_volume_for_bus(bus))
	
	var buses_are_muted: bool = IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.MutedAudioSetting]
	update_audio_section(IndieBlueprintGameSettings.MutedAudioSetting, buses_are_muted)
	
	if(buses_are_muted):
		IndieBlueprintAudioManager.mute_all_buses()
	else:
		IndieBlueprintAudioManager.unmute_all_buses()
		

func create_graphics_section() -> void:
	update_graphics_section(IndieBlueprintGameSettings.FpsCounterSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.FpsCounterSetting])
	update_graphics_section(IndieBlueprintGameSettings.MaxFpsSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.MaxFpsSetting])
	update_graphics_section(IndieBlueprintGameSettings.CurrentMonitorSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.CurrentMonitorSetting])
	update_graphics_section(IndieBlueprintGameSettings.WindowDisplaySetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.WindowDisplaySetting])
	update_graphics_section(IndieBlueprintGameSettings.WindowDisplayBorderlessSetting,  IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.WindowDisplayBorderlessSetting])
	update_graphics_section(IndieBlueprintGameSettings.WindowResolutionSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.WindowResolutionSetting])
	update_graphics_section(IndieBlueprintGameSettings.IntegerScalingSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.IntegerScalingSetting])
	update_graphics_section(IndieBlueprintGameSettings.VsyncSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.VsyncSetting])
	update_graphics_section(IndieBlueprintGameSettings.Scaling3DMode, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.Scaling3DMode])
	update_graphics_section(IndieBlueprintGameSettings.Scaling3DValue, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.Scaling3DValue])
	update_graphics_section(IndieBlueprintGameSettings.QualityPresetSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.QualityPresetSetting])
	

func create_accessibility_section() -> void:
	update_accessibility_section(IndieBlueprintGameSettings.ControllerSensivitySetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.ControllerSensivitySetting])
	update_accessibility_section(IndieBlueprintGameSettings.MouseSensivitySetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.MouseSensivitySetting])
	update_accessibility_section(IndieBlueprintGameSettings.ReversedMouseSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.ReversedMouseSetting])
	update_accessibility_section(IndieBlueprintGameSettings.ControllerVibrationSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.ControllerVibrationSetting])
	update_accessibility_section(IndieBlueprintGameSettings.CameraFovSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.CameraFovSetting])
	update_accessibility_section(IndieBlueprintGameSettings.ScreenBrightnessSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.ScreenBrightnessSetting])
	update_accessibility_section(IndieBlueprintGameSettings.ScreenContrastSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.ScreenContrastSetting])
	update_accessibility_section(IndieBlueprintGameSettings.ScreenSaturationSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.ScreenSaturationSetting])
	update_accessibility_section(IndieBlueprintGameSettings.PhotosensitivitySetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.PhotosensitivitySetting])
	update_accessibility_section(IndieBlueprintGameSettings.ScreenShakeSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.ScreenShakeSetting])
	update_accessibility_section(IndieBlueprintGameSettings.DaltonismSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.DaltonismSetting])


func create_localization_section() -> void:
	update_localization_section(IndieBlueprintGameSettings.CurrentLanguageSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.CurrentLanguageSetting])
	update_localization_section(IndieBlueprintGameSettings.VoicesLanguageSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.VoicesLanguageSetting])
	update_localization_section(IndieBlueprintGameSettings.SubtitlesLanguageSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.SubtitlesLanguageSetting])
	update_localization_section(IndieBlueprintGameSettings.SubtitlesEnabledSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.SubtitlesEnabledSetting])


func create_analytics_section() -> void:
	update_analytics_section(IndieBlueprintGameSettings.AllowTelemetrySetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.AllowTelemetrySetting])


func create_keybindings_section() -> void:
	_get_input_map_actions().map(create_keybinding_events_for_action)
	update_keybindings_section(IndieBlueprintGameSettings.DefaultInputMapActionsSetting, IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.DefaultInputMapActionsSetting])
#endregion


func create_keybinding_events_for_action(action: StringName) -> Array[String]:
	var keybinding_events: Array[String] = []
	var all_inputs_for_action: Array[InputEvent] = IndieBlueprintInputHelper.get_all_inputs_for_action(action)
	## We save the default input map actions to allow players reset to factory default
	IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.DefaultInputMapActionsSetting][action] = all_inputs_for_action
	
	for input_event: InputEvent in all_inputs_for_action:
		if input_event is InputEventKey:
			keybinding_events.append("InputEventKey:%s" %  IndieBlueprintStringHelper.remove_whitespaces(IndieBlueprintInputHelper.readable_key(input_event)))
			
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
			
			if(IndieBlueprintGamepadControllerManager.current_controller_is_xbox() or IndieBlueprintGamepadControllerManager.current_controller_is_generic()):
				joypadButton = "%s Button" % IndieBlueprintGamepadControllerManager.XboxButtonLabels[input_event.button_index]
			
			elif IndieBlueprintGamepadControllerManager.current_controller_is_switch() or IndieBlueprintGamepadControllerManager.current_controller_is_switch_joycon():
				joypadButton = "%s Button" % IndieBlueprintGamepadControllerManager.SwitchButtonLabels[input_event.button_index]
			
			elif  IndieBlueprintGamepadControllerManager.current_controller_is_playstation():
				joypadButton = "%s Button" % IndieBlueprintGamepadControllerManager.PlaystationButtonLabels[input_event.button_index]
				
			keybinding_events.append("InputEventJoypadButton%s%d%s%s" % [InputEventSeparator, input_event.button_index, InputEventSeparator, joypadButton])
	
	
	update_keybindings_section(action, KeybindingSeparator.join(keybinding_events))
	
	return keybinding_events


#region Load
func load_audio() -> void:
	var muted_buses: bool = get_audio_section(IndieBlueprintGameSettings.MutedAudioSetting)
	
	for bus in config_file_api.get_section_keys(IndieBlueprintGameSettings.AudioSection):
		if bus in IndieBlueprintAudioManager.enumerate_available_buses():
			IndieBlueprintAudioManager.change_volume(bus, get_audio_section(bus))
			IndieBlueprintAudioManager.mute_bus(bus, muted_buses)
		
@warning_ignore("int_as_enum_without_cast")
func load_graphics() -> void:
	var viewport: Viewport = get_viewport()
	var window: Window = get_window()
	
	for section_key: String in config_file_api.get_section_keys(IndieBlueprintGameSettings.GraphicsSection):
		var config_value = get_graphics_section(section_key)
		
		match section_key:
			IndieBlueprintGameSettings.MaxFpsSetting:
				Engine.max_fps = config_value
			IndieBlueprintGameSettings.CurrentMonitorSetting:
				if config_value < DisplayServer.get_screen_count():
					window.current_screen = config_value
				else:
					window.current_screen = IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.CurrentMonitorSetting]
			IndieBlueprintGameSettings.WindowDisplaySetting:
				DisplayServer.window_set_mode(config_value)
			IndieBlueprintGameSettings.WindowDisplayBorderlessSetting:
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, bool(config_value))
			IndieBlueprintGameSettings.WindowResolutionSetting:
				DisplayServer.window_set_size(config_value)
			IndieBlueprintGameSettings.IntegerScalingSetting:
				@warning_ignore("int_as_enum_without_cast")
				get_tree().root.content_scale_stretch = int(config_value)
			IndieBlueprintGameSettings.Scaling3DMode:
				viewport.scaling_3d_mode = config_value
			IndieBlueprintGameSettings.Scaling3DValue:
				if viewport.scaling_3d_mode == Viewport.SCALING_3D_MODE_BILINEAR:
					viewport.scaling_3d_scale = config_value
			IndieBlueprintGameSettings.Scaling3DFSRValue:
				if viewport.scaling_3d_mode != Viewport.SCALING_3D_MODE_BILINEAR:
					viewport.scaling_3d_scale = config_value
			IndieBlueprintGameSettings.VsyncSetting:
				DisplayServer.window_set_vsync_mode(config_value)
	
		updated_setting_section.emit(IndieBlueprintGameSettings.GraphicsSection, section_key, config_value)
		


func load_localization() -> void:
	for section_key: String in config_file_api.get_section_keys(IndieBlueprintGameSettings.LocalizationSection):
		var config_value = get_localization_section(section_key)
		
		match section_key:
			IndieBlueprintGameSettings.CurrentLanguageSetting:
				TranslationServer.set_locale(config_value)
				
		updated_setting_section.emit(IndieBlueprintGameSettings.LocalizationSection, section_key, config_value)
		

func load_keybindings() -> void:
	IndieBlueprintGameSettings.DefaultSettings[IndieBlueprintGameSettings.DefaultInputMapActionsSetting] = get_keybindings_section(IndieBlueprintGameSettings.DefaultInputMapActionsSetting)
	
	for action: String in config_file_api.get_section_keys(IndieBlueprintGameSettings.KeybindingsSection):
		if action in [IndieBlueprintGameSettings.DefaultInputMapActionsSetting]:
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
	return config_file_api.get_value(IndieBlueprintGameSettings.AudioSection, key)


func get_keybindings_section(key: String):
	return config_file_api.get_value(IndieBlueprintGameSettings.KeybindingsSection, key)


func get_graphics_section(key: String):
	return config_file_api.get_value(IndieBlueprintGameSettings.GraphicsSection, key)


func get_accessibility_section(key: String):
	return config_file_api.get_value(IndieBlueprintGameSettings.AccessibilitySection, key)


func get_controls_section(key: String):
	return config_file_api.get_value(IndieBlueprintGameSettings.ControlsSection, key)


func get_localization_section(key: String):
	return config_file_api.get_value(IndieBlueprintGameSettings.LocalizationSection, key)
	
func get_analytics_section(key: String):
	return config_file_api.get_value(IndieBlueprintGameSettings.AnalyticsSection, key)

#endregion
	
#region Section updaters
func update_audio_section(key: String, value: Variant) -> void:
	config_file_api.set_value(IndieBlueprintGameSettings.AudioSection, key, value)
	
	updated_setting_section.emit(IndieBlueprintGameSettings.AudioSection, key, value)


func update_keybindings_section(key: String, value: Variant) -> void:
	config_file_api.set_value(IndieBlueprintGameSettings.KeybindingsSection, key, value)
	
	updated_setting_section.emit(IndieBlueprintGameSettings.KeybindingsSection, key, value)


func update_graphics_section(key: String, value: Variant) -> void:
	config_file_api.set_value(IndieBlueprintGameSettings.GraphicsSection, key, value)
	
	updated_setting_section.emit(IndieBlueprintGameSettings.GraphicsSection, key, value)

	
func update_accessibility_section(key: String, value: Variant) -> void:
	config_file_api.set_value(IndieBlueprintGameSettings.AccessibilitySection, key, value)
	
	updated_setting_section.emit(IndieBlueprintGameSettings.AccessibilitySection, key, value)
	

func update_controls_section(key: String, value: Variant) -> void:
	config_file_api.set_value(IndieBlueprintGameSettings.ControlsSection, key, value)
	
	updated_setting_section.emit(IndieBlueprintGameSettings.ControlsSection, key, value)
	

func update_analytics_section(key: String, value: Variant) -> void:
	config_file_api.set_value(IndieBlueprintGameSettings.AnalyticsSection, key, value)
	
	updated_setting_section.emit(IndieBlueprintGameSettings.AnalyticsSection, key, value)
	

func update_localization_section(key: String, value: Variant) -> void:
	config_file_api.set_value(IndieBlueprintGameSettings.LocalizationSection, key, value)

	updated_setting_section.emit(IndieBlueprintGameSettings.LocalizationSection, key, value)
	
#endregion

#region Private functions
func _add_keybinding_event(action: String, keybinding_type: Array[String] = []):
	var keybinding_modifiers_regex = RegEx.new()
	keybinding_modifiers_regex.compile(r"\b(Shift|Ctrl|Alt)\+\b")
	
	match keybinding_type[0]:
		"InputEventKey":
			var input_event_key = InputEventKey.new()
			input_event_key.keycode = OS.find_keycode_from_string(IndieBlueprintStringHelper.str_replace(keybinding_type[1].strip_edges(), keybinding_modifiers_regex, func(_text: String): return ""))
			input_event_key.alt_pressed = not IndieBlueprintStringHelper.equals_ignore_case(keybinding_type[1], "alt") and keybinding_type[1].containsn("alt")
			input_event_key.ctrl_pressed = not IndieBlueprintStringHelper.equals_ignore_case(keybinding_type[1], "ctrl") and keybinding_type[1].containsn("ctrl")
			input_event_key.shift_pressed = not IndieBlueprintStringHelper.equals_ignore_case(keybinding_type[1], "shift") and keybinding_type[1].containsn("shift")
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
func apply_graphics_on_directional_light(directional_light: DirectionalLight3D, quality_preset: IndieBlueprintHardwareDetector.QualityPreset = IndieBlueprintHardwareDetector.QualityPreset.Medium) -> void:
	var preset: IndieBlueprintHardwareDetector.GraphicQualityPreset = IndieBlueprintHardwareDetector.graphics_quality_presets[quality_preset]
	
	for quality: IndieBlueprintHardwareDetector.GraphicQualityDisplay in preset.quality:
		match quality.project_setting:
			"shadow_atlas":
				match quality_preset:
					IndieBlueprintHardwareDetector.QualityPreset.Low:
						directional_light.shadow_bias = 0.03
					IndieBlueprintHardwareDetector.QualityPreset.Medium:
						directional_light.shadow_bias = 0.02
					IndieBlueprintHardwareDetector.QualityPreset.High:
						directional_light.shadow_bias = 0.01
					IndieBlueprintHardwareDetector.QualityPreset.Ultra:
						directional_light.shadow_bias = 0.005


@warning_ignore("int_as_enum_without_cast")
func apply_graphics_on_environment(world_environment: WorldEnvironment, quality_preset: IndieBlueprintHardwareDetector.QualityPreset = IndieBlueprintHardwareDetector.QualityPreset.Medium) -> void:
	var viewport: Viewport = world_environment.get_viewport()
	var preset: IndieBlueprintHardwareDetector.GraphicQualityPreset = IndieBlueprintHardwareDetector.graphics_quality_presets[quality_preset]
	
	for quality: IndieBlueprintHardwareDetector.GraphicQualityDisplay in preset.quality:
		match quality.project_setting:
			"environment/glow_enabled":
				world_environment.environment.glow_enabled = bool(quality.enabled)
			"environment/ssao_enabled":
				world_environment.environment.ssao_enabled = bool(quality.enabled)
				
				if world_environment.environment.ssao_enabled:
					match quality_preset:
						IndieBlueprintHardwareDetector.QualityPreset.Low:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
						IndieBlueprintHardwareDetector.QualityPreset.Medium:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
						IndieBlueprintHardwareDetector.QualityPreset.High:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
						IndieBlueprintHardwareDetector.QualityPreset.Ultra:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
			"environment/ss_reflections_enabled":
				world_environment.environment.ssr_enabled = bool(quality.enabled)
				
				if world_environment.environment.ssr_enabled:
					match quality_preset:
						IndieBlueprintHardwareDetector.QualityPreset.Low:
							world_environment.environment.ssr_max_steps = 8
						IndieBlueprintHardwareDetector.QualityPreset.Medium:
							world_environment.environment.ssr_max_steps = 32
						IndieBlueprintHardwareDetector.QualityPreset.High:
							world_environment.environment.ssr_max_steps = 56
						IndieBlueprintHardwareDetector.QualityPreset.Ultra:
							world_environment.environment.ssr_max_steps = 56
			"environment/sdfgi_enabled":
				world_environment.environment.sdfgi_enabled = bool(quality.enabled)
				
				if world_environment.environment.sdfgi_enabled:
					match quality_preset:
						IndieBlueprintHardwareDetector.QualityPreset.Low:
							RenderingServer.gi_set_use_half_resolution(true)
						IndieBlueprintHardwareDetector.QualityPreset.Medium:
							RenderingServer.gi_set_use_half_resolution(true)
						IndieBlueprintHardwareDetector.QualityPreset.High:
							RenderingServer.gi_set_use_half_resolution(false)
						IndieBlueprintHardwareDetector.QualityPreset.Ultra:
							RenderingServer.gi_set_use_half_resolution(false)
			"environment/ssil_enabled":
				world_environment.environment.ssil_enabled = bool(quality.enabled)
			"rendering/anti_aliasing/quality/msaa_3d":
				@warning_ignore("int_as_enum_without_cast")
				viewport.msaa_3d = quality.enabled
			"shadow_atlas":
				RenderingServer.directional_shadow_atlas_set_size(quality.enabled, true)
				viewport.positional_shadow_atlas_size = quality.enabled
			"shadow_filter":
				RenderingServer.directional_soft_shadow_filter_set_quality(quality.enabled)
				RenderingServer.positional_soft_shadow_filter_set_quality(quality.enabled)
			"mesh_level_of_detail":
				viewport.mesh_lod_threshold = quality.enabled
			"scaling_3d":
				if viewport.scaling_3d_mode == Viewport.SCALING_3D_MODE_BILINEAR:
					viewport.scaling_3d_scale = quality.enabled
			"scaling_3d_fsr":
				if viewport.scaling_3d_mode != Viewport.SCALING_3D_MODE_BILINEAR:
					## When using FSR upscaling, AMD recommends exposing the following values as preset options to users 
					## "Ultra Quality: 0.77", "Quality: 0.67", "Balanced: 0.59", "Performance: 0.5" instead of exposing the entire scale.
					viewport.scaling_3d_scale = quality.enabled
#endregion
	

func _get_input_map_actions() -> Array[StringName]:
	return InputMap.get_actions() if include_ui_keybindings else InputMap.get_actions().filter(func(action): return !action.contains("ui_"))


func encription_key() -> StringName:
	return (&"%s%s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/description")]).sha256_text()

#region Signal callbacks
func on_updated_setting_section(_section: String, _key: String, _value: Variant) -> void:
	save_settings()
#endregion
