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
const WindowDisplaySetting: StringName = &"window_display"
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
const SubtitlesEnabledSetting: StringName = &"subtitles_enabled"

const MutedAudioSetting: StringName = &"muted_audio"

const DefaultInputMapActionsSetting: StringName = &"default_input_map_actions"
#endregion


#region Default settings
static var DefaultSettings: Dictionary = {
	IndieBlueprintGameSettings.DefaultInputMapActionsSetting: {}
}

#endregion
