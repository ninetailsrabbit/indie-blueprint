class_name GameSettings

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
const WindowDisplaySetting: StringName = &"display"
const WindowDisplayBorderlessSetting: StringName = &"borderless"
const WindowResolutionSetting: StringName = &"resolution"
const VsyncSetting: StringName = &"vsync"
const QualityPresetSetting: StringName = &"quality_preset"

const MouseSensivitySetting: StringName = &"mouse_sensitivity"
const ReversedMouseSetting: StringName = &"reversed_mouse"
const ControllerVibrationSetting: StringName = &"controller_vibration"

const ScreenBrightnessSetting: StringName = &"screen_brightness"
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
	GameSettings.MutedAudioSetting: false,
	GameSettings.FpsCounterSetting: false,
	GameSettings.MaxFpsSetting: 0,
	GameSettings.WindowDisplaySetting: DisplayServer.window_get_mode(),
	GameSettings.WindowResolutionSetting: DisplayServer.window_get_size(),
	GameSettings.WindowDisplayBorderlessSetting: DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS),
	GameSettings.VsyncSetting:  DisplayServer.window_get_vsync_mode(),
	GameSettings.QualityPresetSetting: HardwareDetector.auto_discover_graphics_quality(),
	GameSettings.MouseSensivitySetting: 3.0,
	GameSettings.ReversedMouseSetting: false,
	GameSettings.ControllerVibrationSetting: true,
	GameSettings.ScreenBrightnessSetting: 1.0,
	GameSettings.PhotosensitivitySetting: false,
	GameSettings.ScreenShakeSetting: true,
	GameSettings.DaltonismSetting: WindowManager.DaltonismTypes.No,
	GameSettings.CurrentLanguageSetting: TranslationServer.get_locale(),
	GameSettings.VoicesLanguageSetting: TranslationServer.get_locale(),
	GameSettings.SubtitlesLanguageSetting: TranslationServer.get_locale(),
	GameSettings.SubtitlesEnabledSetting: false,
	GameSettings.AllowTelemetrySetting: false,
	## Dictionary[StringName, Array[InputEvent]
	GameSettings.DefaultInputMapActionsSetting: {}
}

static var FpsLimits: Array[int] = [0, 30, 60, 90, 144, 240, 300]
#endregion
