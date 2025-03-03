@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton(IndieBlueprintAudioSettings.AudioManagerSingleton, "res://addons/ninetailsrabbit.indie_blueprint_audio/src/audio_manager.gd")
	add_autoload_singleton(IndieBlueprintAudioSettings.MusicManagerSingleton, "res://addons/ninetailsrabbit.indie_blueprint_audio/src/music_manager.gd")
	add_autoload_singleton(IndieBlueprintAudioSettings.SoundPoolSingleton, "res://addons/ninetailsrabbit.indie_blueprint_audio/src/sound_pool.gd")
	
	IndieBlueprintAudioSettings.setup_sound_pool_settings()
	
	add_custom_type(
		"IndieBlueprintSoundQueue", 
		"Node", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_audio/src/components/queue/sound_queue.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_audio/src/components/queue/sound_queue.svg")
	)
	
	add_custom_type("ConsumableAudioStreamPlayer",
		 "AudioStreamPlayer",
		 preload("res://addons/ninetailsrabbit.indie_blueprint_audio/src/components/consumables/consumable_audio_stream_player.gd"),
		 null
	)
	
	add_custom_type("ConsumableAudioStreamPlayer2D",
		 "AudioStreamPlayer2D",
		 preload("res://addons/ninetailsrabbit.indie_blueprint_audio/src/components/consumables/consumable_audio_stream_player_2d.gd"),
		 null
	)
	
	add_custom_type("ConsumableAudioStreamPlayer3D",
		 "AudioStreamPlayer3D",
		 preload("res://addons/ninetailsrabbit.indie_blueprint_audio/src/components/consumables/consumable_audio_stream_player_3d.gd"),
		 null
	)
	
	
func _exit_tree() -> void:
	remove_custom_type("ConsumableAudioStreamPlayer3D")
	remove_custom_type("ConsumableAudioStreamPlayer2D")
	remove_custom_type("ConsumableAudioStreamPlayer")
	remove_custom_type("IndieBlueprintSoundQueue")
	
	remove_autoload_singleton(IndieBlueprintAudioSettings.SoundPoolSingleton)
	remove_autoload_singleton(IndieBlueprintAudioSettings.MusicManagerSingleton)
	remove_autoload_singleton(IndieBlueprintAudioSettings.AudioManagerSingleton)
