class_name AudioSlider extends HSlider

@export_enum(&"Master", &"Music", &"SFX", &"EchoSFX", &"Voice", &"UI", &"Ambient") var target_bus: String = IndieBlueprintAudioManager.MusicBus


func _enter_tree() -> void:
	name = "%sAudioSlider" % target_bus
	
	min_value = 0.0
	max_value = 1.0
	step = 0.001
	
	drag_ended.connect(audio_slider_drag_ended)


func _ready() -> void:
	value = IndieBlueprintAudioManager.get_actual_volume_db_from_bus(target_bus)


func audio_slider_drag_ended(volume_changed: bool):
	if volume_changed:
		
		if(target_bus == IndieBlueprintAudioManager.SFXBus):
			IndieBlueprintAudioManager.change_volume(IndieBlueprintAudioManager.EchoSFXBus, value)
			
		IndieBlueprintAudioManager.change_volume(target_bus, value)
		IndieBlueprintSettingsManager.update_audio_section(target_bus, value)
