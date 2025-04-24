@tool
class_name IndieBlueprintToolboxSettings extends RefCounted

const PluginPrefixName: String = "ninetailsrabbit.indie_blueprint_toolbox" ## The folder name
const GitRepositoryName: String = "indie-blueprint-toolbox"

static var PluginName: String = "Indie Blueprint Toolbox"
static var PluginProjectName: String = ProjectSettings.get_setting("application/config/name")
static var PluginBasePath: String = "res://addons/%s" % PluginPrefixName
static var PluginLocalConfigFilePath = "%s/plugin.cfg" % PluginBasePath
static var PluginSettingsBasePath: String = "%s/config/%s" % [PluginProjectName, PluginPrefixName]
static var RemoteReleasesUrl = "https://api.github.com/repos/ninetailsrabbit/%s/releases" % GitRepositoryName
static var PluginTemporaryDirectoryPath = OS.get_user_data_dir() + "/" + PluginPrefixName
static var PluginTemporaryReleaseUpdateDirectoryPath = "%s/update" % PluginTemporaryDirectoryPath
static var PluginTemporaryReleaseFilePath = "%s/%s.zip" % [PluginTemporaryDirectoryPath, PluginPrefixName]
static var PluginDebugDirectoryPath = "res://debug"

#region Plugin Settings
static var OutputPreloaderPathSetting: String = PluginSettingsBasePath + "/output_path"
static var  PreloaderClassNameSetting: String = PluginSettingsBasePath + "/preloader_filename"

static var EnableTimerSetting: String = PluginSettingsBasePath + "/enable_timer"
static var PreloaderUpdateFrequencySetting: String = PluginSettingsBasePath + "/update_frequency"
static var IncludeScriptsSetting: String = PluginSettingsBasePath + "/include_scripts"
static var IncludeScenesSetting: String = PluginSettingsBasePath + "/include_scenes"
static var IncludeResourcesSetting: String = PluginSettingsBasePath + "/include_resources"
static var IncludeShadersSetting: String = PluginSettingsBasePath + "/include_shaders"

static var ExcludePathSetting: String = PluginSettingsBasePath + "/exclude_paths"
static var ImageTypesSetting: String = PluginSettingsBasePath + "/image_types"
static var AudioTypesSetting: String = PluginSettingsBasePath + "/audio_types"
static var FontTypesSetting: String = PluginSettingsBasePath + "/font_types"
#endregion

## Enable to test the updater without need to have a latest release version to trigger it
static var DebugMode: bool = false


static func setup_preloader_output_path(path: StringName = &"res://addons/ninetailsrabbit.indie_blueprint_toolbox/src") -> void:
	ProjectSettings.set_setting(OutputPreloaderPathSetting, path)
	ProjectSettings.add_property_info({
		"name": OutputPreloaderPathSetting,
		"type": TYPE_STRING_NAME,
	 	"value": path,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "The output path to generate and save the preloader file. Only supports absolute paths"
	})
	
	ProjectSettings.set_initial_value(OutputPreloaderPathSetting, path)
	ProjectSettings.save()


static func setup_preloader_classname(filename: StringName = &"IndieBlueprintPreloader") -> void:
	ProjectSettings.set_setting(PreloaderClassNameSetting, filename)
	ProjectSettings.add_property_info({
		"name": PreloaderClassNameSetting,
		"type": TYPE_STRING_NAME,
	 	"value": filename,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "The class name of the preloader file to access it"
	})
	
	ProjectSettings.set_initial_value(PreloaderClassNameSetting, filename)
	ProjectSettings.save()


static func setup_enable_timer(enabled: bool = OS.is_debug_build()) -> void:
	ProjectSettings.set_setting(EnableTimerSetting, enabled)
	ProjectSettings.add_property_info({
		"name": EnableTimerSetting,
		"type": TYPE_BOOL,
	 	"value": enabled,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Enable the timer to update frequently the preloader file"
	})
	
	ProjectSettings.set_initial_value(EnableTimerSetting, enabled)
	ProjectSettings.save()


static func setup_preloader_update_frequency(time: float = 600.0) -> void:
	ProjectSettings.set_setting(PreloaderUpdateFrequencySetting, time)
	ProjectSettings.add_property_info({
		"name": PreloaderUpdateFrequencySetting,
		"type": TYPE_FLOAT,
	 	"value": time,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Set the frequency time to update the preloader files from your project"
	})
	
	ProjectSettings.set_initial_value(PreloaderUpdateFrequencySetting, time)
	ProjectSettings.save()


static func setup_include_scripts(include: bool = true) -> void:
	ProjectSettings.set_setting(IncludeScriptsSetting, include)
	ProjectSettings.add_property_info({
		"name": IncludeScriptsSetting,
		"type": TYPE_BOOL,
	 	"value": include,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Include gdscript files .gd"
	})
	
	ProjectSettings.set_initial_value(IncludeScriptsSetting, include)
	ProjectSettings.save()
	

static func setup_include_scenes(include: bool = true) -> void:
	ProjectSettings.set_setting(IncludeScenesSetting, include)
	ProjectSettings.add_property_info({
		"name": IncludeScenesSetting,
		"type": TYPE_BOOL,
	 	"value": include,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Include scene files .tscn, .scn"
	})
	
	ProjectSettings.set_initial_value(IncludeScenesSetting, include)
	ProjectSettings.save()
	
	
static func setup_include_resources(include: bool = true) -> void:
	ProjectSettings.set_setting(IncludeResourcesSetting, include)
	ProjectSettings.add_property_info({
		"name": IncludeResourcesSetting,
		"type": TYPE_BOOL,
	 	"value": include,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Include resource files .res, .tres"
	})
	
	ProjectSettings.set_initial_value(IncludeResourcesSetting, include)
	ProjectSettings.save()
	
	
static func setup_include_shaders(include: bool = true) -> void:
	ProjectSettings.set_setting(IncludeShadersSetting, include)
	ProjectSettings.add_property_info({
		"name": IncludeShadersSetting,
		"type": TYPE_BOOL,
	 	"value": include,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Include shader files .gdshader"
	})
	
	ProjectSettings.set_initial_value(IncludeShadersSetting, include)
	ProjectSettings.save()
	
	
static func setup_exclude_paths(types: Array[String] = ["addons"]) -> void:
	ProjectSettings.set_setting(ExcludePathSetting, types)
	ProjectSettings.add_property_info({
		"name": ExcludePathSetting,
		"type": TYPE_ARRAY,
	 	"value": types,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Set the excluded paths in the format addons/subfolder/..."
	})
	
	ProjectSettings.set_initial_value(ExcludePathSetting, types)
	ProjectSettings.save()


static func setup_supported_image_types(types: Array[String] = ["png", "jpg", "jpeg", "gif", "bmp", "svg", "webp", "heic"]) -> void:
	ProjectSettings.set_setting(ImageTypesSetting, types)
	ProjectSettings.add_property_info({
		"name": ImageTypesSetting,
		"type": TYPE_ARRAY,
	 	"value": types,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Set the supported image types to preload"
	})
	
	ProjectSettings.set_initial_value(ImageTypesSetting, types)
	ProjectSettings.save()


static func setup_supported_audio_types(types: Array[String] = ["wav", "ogg", "mp3", "aac", "flac", "opus", "m4a", "wma"]) -> void:
	ProjectSettings.set_setting(AudioTypesSetting, types)
	ProjectSettings.add_property_info({
		"name": AudioTypesSetting,
		"type": TYPE_ARRAY,
	 	"value": types,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Set the supported audio types to preload"
	})
	
	ProjectSettings.set_initial_value(AudioTypesSetting, types)
	ProjectSettings.save()


static func setup_supported_font_types(types: Array[String] = ["ttf", "otf", "woff", "woff2", "eot"]) -> void:
	ProjectSettings.set_setting(FontTypesSetting, types)
	ProjectSettings.add_property_info({
		"name": FontTypesSetting,
		"type": TYPE_ARRAY,
	 	"value": types,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Set the supported font types to preload"
	})
	
	ProjectSettings.set_initial_value(FontTypesSetting, types)
	ProjectSettings.save()


static func remove_setting(name: String) -> void:
	if ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, null)
		ProjectSettings.save()
