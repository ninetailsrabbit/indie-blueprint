class_name MutedAudioCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = IndieBlueprintAudioManager.all_buses_are_muted()
	toggled.connect(on_mute_audio_changed)


func on_mute_audio_changed(enabled: bool) -> void:
	if(enabled):
		IndieBlueprintAudioManager.mute_all_buses()
	else:
		IndieBlueprintAudioManager.unmute_all_buses()
		
	IndieBlueprintSettingsManager.update_audio_section(IndieBlueprintGameSettings.MutedAudioSetting, enabled)
