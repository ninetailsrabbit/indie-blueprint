@tool
class_name InteractionKit3DPluginSettings extends RefCounted

const PluginPrefixName: String = "ninetailsrabbit.interaction_kit_3d" ## The folder name
const GitRepositoryName: String = "interaction-kit-3d"

static var PluginName: String = "InteractionKit3D"
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
static var InteractablesCollisionLayerSetting: String = PluginSettingsBasePath + "/interactables_collision_layer"
static var GrabbablesCollisionLayerSetting: String = PluginSettingsBasePath + "/grabbables_collision_layer"
#endregion

## Enable to test the updater without need to have a latest release version to trigger it
static var DebugMode: bool = false
static var GlobalInteractionEventsSingleton: String = "GlobalInteractionEvents"

## By default on layer 5
static func set_interactable_collision_layer(interactable_layer: int = 6) -> void:
	interactable_layer = clampi(interactable_layer, 1, 32)
	
	ProjectSettings.set_setting(InteractablesCollisionLayerSetting, interactable_layer)
	ProjectSettings.add_property_info({
		"name": InteractablesCollisionLayerSetting,
		"type": typeof(interactable_layer),
	 	"value": interactable_layer,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Set the collision layer for interactables to be detected by interactors"
	})
	ProjectSettings.save()


## By default on layer 6
static func set_grabbable_collision_layer(grabbable_layer: int = 7) -> void:
	grabbable_layer = clamp(grabbable_layer, 1, 32)
	
	ProjectSettings.set_setting(GrabbablesCollisionLayerSetting, grabbable_layer)
	ProjectSettings.add_property_info({
		"name": GrabbablesCollisionLayerSetting,
		"type": typeof(grabbable_layer),
	 	"value": grabbable_layer,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Set the collision layer for grabbables to be detected by the grabber"
	})
	ProjectSettings.save()


static func remove_settings() -> void:
	remove_setting(InteractablesCollisionLayerSetting)
	remove_setting(GrabbablesCollisionLayerSetting)


static func remove_setting(name: String) -> void:
	if ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, null)
		ProjectSettings.save()
		
