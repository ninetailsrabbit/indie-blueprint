class_name IndieBlueprintGameSettings

#region ConfigFile sections
const KeybindingsSection: StringName = &"keybindings"
const GraphicsSection: StringName = &"graphics"
const AudioSection: StringName = &"audio"
const ControlsSection: StringName = &"controls"
const AccessibilitySection: StringName = &"accessibility"
const LocalizationSection: StringName = &"localization"
const AnalyticsSection: StringName = &"analytics"
#endregion

#region Setting properties
## This settings are used as keys for the configuration file .ini or .cfg
const FpsCounterSetting: StringName = &"fps_counter"
const MaxFpsSetting: StringName = &"max_fps"
const CurrentMonitorSetting: StringName = &"current_monitor"
const WindowDisplaySetting: StringName = &"display"
const WindowDisplayBorderlessSetting: StringName = &"borderless"
const WindowResolutionSetting: StringName = &"resolution"
const IntegerScalingSetting: StringName = &"integer_scaling"
const VsyncSetting: StringName = &"vsync"
const Scaling3DMode: StringName = &"scaling_3d_mode"
const Scaling3DFSRValue: StringName = &"scaling_3d_fsr_value"
const Scaling3DValue: StringName = &"scaling_3d_value"
const QualityPresetSetting: StringName = &"quality_preset"

const ControllerSensivitySetting: StringName = &"controller_sensitivity"
const MouseSensivitySetting: StringName = &"mouse_sensitivity"
const ReversedMouseSetting: StringName = &"reversed_mouse"
const ControllerVibrationSetting: StringName = &"controller_vibration"
const CameraFovSetting: StringName = &"camera_fov"

const ScreenBrightnessSetting: StringName = &"screen_brightness"
const ScreenContrastSetting: StringName = &"screen_contrast"
const ScreenSaturationSetting: StringName = &"screen_saturation"
const PhotosensitivitySetting: StringName = &"photosensitive"
const ScreenShakeSetting: StringName = &"screenshake"
const DaltonismSetting: StringName = &"daltonism"

const AllowTelemetrySetting: StringName = &"allow_telemetry"

const CurrentLanguageSetting: String = "current_language"
const VoicesLanguageSetting: String = "voices_language"
const SubtitlesLanguageSetting: String = "subtitles_language"
const SubtitlesEnabledSetting: StringName = &"subtitles"

const MutedAudioSetting: StringName = &"muted"

const DefaultInputMapActionsSetting: StringName = &"default_input_map_actions"
#endregion


#region Default settings
static var DefaultSettings: Dictionary = {
	IndieBlueprintGameSettings.MutedAudioSetting: false,
	IndieBlueprintGameSettings.FpsCounterSetting: false,
	IndieBlueprintGameSettings.MaxFpsSetting: 0,
	IndieBlueprintGameSettings.CurrentMonitorSetting: 0,
	IndieBlueprintGameSettings.WindowDisplaySetting: DisplayServer.window_get_mode(),
	IndieBlueprintGameSettings.WindowResolutionSetting: DisplayServer.window_get_size(),
	IndieBlueprintGameSettings.WindowDisplayBorderlessSetting: DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS),
	IndieBlueprintGameSettings.IntegerScalingSetting: 1 if ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer" else 0,
	IndieBlueprintGameSettings.VsyncSetting:  DisplayServer.window_get_vsync_mode(),
	IndieBlueprintGameSettings.Scaling3DMode: Viewport.SCALING_3D_MODE_BILINEAR,
	IndieBlueprintGameSettings.Scaling3DValue: 1.0,
	IndieBlueprintGameSettings.Scaling3DFSRValue: 0.59,
	IndieBlueprintGameSettings.QualityPresetSetting: IndieBlueprintHardwareDetector.auto_discover_graphics_quality(),
	IndieBlueprintGameSettings.ControllerSensivitySetting: 5.0,
	IndieBlueprintGameSettings.MouseSensivitySetting: 3.0,
	IndieBlueprintGameSettings.ReversedMouseSetting: false,
	IndieBlueprintGameSettings.ControllerVibrationSetting: true,
	IndieBlueprintGameSettings.CameraFovSetting: 75.0,
	IndieBlueprintGameSettings.ScreenBrightnessSetting: 1.0,
	IndieBlueprintGameSettings.ScreenContrastSetting: 1.0,
	IndieBlueprintGameSettings.ScreenSaturationSetting: 1.0,
	IndieBlueprintGameSettings.PhotosensitivitySetting: false,
	IndieBlueprintGameSettings.ScreenShakeSetting: true,
	IndieBlueprintGameSettings.DaltonismSetting: IndieBlueprintWindowManager.DaltonismTypes.No,
	IndieBlueprintGameSettings.CurrentLanguageSetting: TranslationServer.get_locale(),
	IndieBlueprintGameSettings.VoicesLanguageSetting: TranslationServer.get_locale(),
	IndieBlueprintGameSettings.SubtitlesLanguageSetting: TranslationServer.get_locale(),
	IndieBlueprintGameSettings.SubtitlesEnabledSetting: false,
	IndieBlueprintGameSettings.AllowTelemetrySetting: false,
	## Dictionary[StringName, Array[InputEvent]
	IndieBlueprintGameSettings.DefaultInputMapActionsSetting: {}
}

static var FpsLimits: Array[int] = [0, 30, 60, 90, 144, 240, 300]
#endregion
