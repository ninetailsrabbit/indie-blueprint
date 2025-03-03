@tool
class_name IndieBlueprintAudioSettings extends RefCounted

const PluginPrefixName: String = "ninetailsrabbit.indie_blueprint_audio" ## The folder name
const GitRepositoryName: String = "indie-blueprint-audio"

static var PluginName: String = "Indie Blueprint Audio"
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
##PluginSettingsBasePath + "/your-setting"
static var SoundPoolAmountSetting: String = PluginSettingsBasePath + "/sound_pool_amount"
#endregion

## Enable to test the updater without need to have a latest release version to trigger it
static var DebugMode: bool = false
static var AudioManagerSingleton: String = "IndieBlueprintAudioManager"
static var MusicManagerSingleton: String = "IndieBlueprintMusicManager"
static var SoundPoolSingleton: String = "IndieBlueprintSoundPool"


static func setup_sound_pool_settings() -> void:
	## https://github.com/godotengine/godot/issues/56598
	var setting_name: String = IndieBlueprintAudioSettings.SoundPoolAmountSetting
	
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, 32)
		ProjectSettings.add_property_info({
				"name": setting_name,
				"type": TYPE_INT,
			})
			
		ProjectSettings.set_initial_value(setting_name, 32)
		ProjectSettings.set_as_basic(setting_name, true)
		ProjectSettings.save()


static func remove_setting(name: String) -> void:
	if ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, null)
		ProjectSettings.save()
