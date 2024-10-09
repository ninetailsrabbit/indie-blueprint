class_name GameSettings

#region ConfigFile sections
const KeybindingsSection: String = "keybindings"
const GraphicsSection: String = "graphics"
const AudioSection: String = "audio"
const ControlsSection: String = "controls"
const AccessibilitySection: String = "accessibility"
const LocalizationSection: String = "localization"
const AnalyticsSection: String = "analytics"
#endregion

#region Setting properties
const FpsCounterSetting: String = "fps_counter"
const MaxFpsSetting: String = "max_fps"
const WindowDisplaySetting: String = "display"
const WindowDisplayBorderlessSetting: String = "borderless"
const WindowResolutionSetting: String = "resolution"
const VsyncSetting: String = "vsync"
const QualityPresetSetting: String = "quality_preset"

const MouseSensivitySetting: String = "mouse_sensitivity"
const ControllerVibrationSetting: String = "controller_vibration"

const ScreenBrightnessSetting: String = "screen_brightness"
const PhotosensitivitySetting: String = "photosensitive"
const ScreenShakeSetting: String = "screenshake"
const DaltonismSetting: String = "daltonism"

const AllowTelemetrySetting: String = "allow_telemetry"

const CurrentLanguageSetting: String = "current_language"
const VoicesLanguageSetting: String = "voices_language"
const SubtitlesLanguageSetting: String = "subtitles_language"
const SubtitlesEnabledSetting: String = "subtitles"

const MutedAudioSetting: String = "muted"
#endregion


#region Default settings
static var DefaultSettings: Dictionary = {
	GameSettings.MutedAudioSetting: false,
	GameSettings.FpsCounterSetting: false,
	GameSettings.MaxFpsSetting: 0,
	GameSettings.WindowDisplaySetting: DisplayServer.window_get_mode(),
	GameSettings.WindowResolutionSetting: DisplayServer.window_get_size(),
	GameSettings.VsyncSetting:  DisplayServer.window_get_vsync_mode(),
	GameSettings.QualityPresetSetting: HardwareDetector.auto_discover_graphics_quality(),
	GameSettings.MouseSensivitySetting: 3.0,
	GameSettings.ControllerVibrationSetting: true,
	GameSettings.ScreenBrightnessSetting: 1.0,
	GameSettings.PhotosensitivitySetting: false,
	GameSettings.ScreenShakeSetting: true,
	GameSettings.DaltonismSetting: WindowManager.DaltonismTypes.No,
	GameSettings.CurrentLanguageSetting: TranslationServer.get_locale(),
	GameSettings.VoicesLanguageSetting: TranslationServer.get_locale(),
	GameSettings.SubtitlesLanguageSetting: TranslationServer.get_locale(),
	GameSettings.SubtitlesEnabledSetting: false,
	GameSettings.AllowTelemetrySetting: false
}

static var FpsLimits: Array[int] = [0, 30, 60, 90, 144, 240, 300]

#endregion
