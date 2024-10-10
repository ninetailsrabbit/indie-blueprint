class_name MutedAudioCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = AudioManager.all_buses_are_muted()
	toggled.connect(on_mute_audio_changed)


func on_mute_audio_changed(enabled: bool) -> void:
	if(enabled):
		AudioManager.mute_all_buses()
	else:
		AudioManager.unmute_all_buses()
		
	SettingsManager.update_audio_section(GameSettings.MutedAudioSetting, enabled)
