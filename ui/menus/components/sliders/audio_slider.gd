class_name AudioSlider extends HSlider

@export_enum("Master", "Music", "SFX", "EchoSFX", "Voice", "UI", "Ambient") var target_bus: String = "Music"


func _enter_tree() -> void:
	name = "%sAudioSlider" % target_bus
	
	min_value = 0.0
	max_value = 1.0
	step = 0.001
	
	drag_ended.connect(audio_slider_drag_ended)


func _ready() -> void:
	value = AudioManager.get_actual_volume_db_from_bus(target_bus)


func audio_slider_drag_ended(volume_changed: bool):
	if volume_changed:
		if(target_bus == "SFX"):
			AudioManager.change_volume("EchoSFX", value)
		AudioManager.change_volume(target_bus, value)
		
		SettingsManager.update_audio_section(target_bus, value)
