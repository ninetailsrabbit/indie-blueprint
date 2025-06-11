class_name MutedAudioCheckbox extends SettingCheckbox


func _ready() -> void:
	super._ready()
	button_pressed = IndieBlueprintAudioManager.all_buses_are_muted()
	

func on_setting_changed(enabled: bool) -> void:
	if(enabled):
		IndieBlueprintAudioManager.mute_all_buses()
	else:
		IndieBlueprintAudioManager.unmute_all_buses()
		
	IndieBlueprintSettingsManager.update_audio_section(IndieBlueprintGameSettings.MutedAudioSetting, enabled)
