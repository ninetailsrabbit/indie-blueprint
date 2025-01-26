extends Node

signal added_track_to_music_bank(track_name: String, stream: AudioStream)
signal removed_track_from_music_bank(track_name: String)
signal changed_stream(from: AudioStream, to: AudioStream)
signal started_stream(audio_stream_player: AudioStreamPlayer, new_stream: AudioStream)
signal finished_stream(audio_stream_player: AudioStreamPlayer, old_stream: AudioStream)

const VolumeDBInaudible: float = -80.0

## Dictionary<String, AudioStream>
var music_bank: Dictionary = {}

#region AudioStreamPlayers
var main_audio_stream_player: AudioStreamPlayer
var secondary_audio_stream_player: AudioStreamPlayer
var current_audio_stream_player: AudioStreamPlayer
#endregion

#region Crossfade
var crossfade_tween: Tween
var default_crossfade_time: float = 5.0
#endregion

func _ready():
	_create_audio_stream_players()


func play_music(stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time):
	if _crossfade_tween_is_running():
		return
		
	var next_stream: AudioStream = music_bank.get(stream_name)
	
	if next_stream == null:
		push_error("MusicManager: Expected music name %s to exists in the MusicBank but no stream was found" % stream_name)
		return
	
	if current_audio_stream_player.is_playing():
		if crossfade:
			var next_audio_stream_player: AudioStreamPlayer = secondary_audio_stream_player if current_audio_stream_player.name == "MainAudioStreamPlayer" else main_audio_stream_player
			next_audio_stream_player.volume_db = VolumeDBInaudible
			play_stream(next_audio_stream_player, next_stream)
			
			var volume: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(next_audio_stream_player.bus))
			
			crossfade_tween = create_tween().set_parallel(true)
			crossfade_tween.tween_property(current_audio_stream_player, "volume_db", VolumeDBInaudible, crossfade_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
			crossfade_tween.tween_property(next_audio_stream_player, "volume_db", volume, crossfade_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
			crossfade_tween.chain().tween_callback(func(): current_audio_stream_player = next_audio_stream_player)
			return
		
	play_stream(current_audio_stream_player, next_stream)
		

func play_stream(player: AudioStreamPlayer, stream: AudioStream):
	if current_audio_stream_player.stream != null:
		changed_stream.emit(current_audio_stream_player.stream, stream)
	
	player.stop()
	player.stream = stream
	player.play()
	
	started_stream.emit(player, stream)
	
	
func pause_current_track() -> void:
	if current_audio_stream_player.stream != null and not current_audio_stream_player.stream_paused:
		current_audio_stream_player.stream_paused = true


func replay_current_track() -> void:
	if current_audio_stream_player.stream != null and current_audio_stream_player.stream_paused:
		current_audio_stream_player.play()
	
	
#region Syntatic sugar to play a music a track
func change_track_to(new_stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	play_music(new_stream_name, crossfade, crossfade_time)


func change_track(new_stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	play_music(new_stream_name, crossfade, crossfade_time)


func change_music(new_stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	play_music(new_stream_name, crossfade, crossfade_time)


func change_music_to(new_stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	play_music(new_stream_name, crossfade, crossfade_time)

#endregion
	
## Dictionary<String, AudioStream>
func add_streams_to_music_bank(streams: Dictionary):
	for stream_name: String in streams:
		add_stream_to_music_bank(stream_name, streams[stream_name])


func add_stream_to_music_bank(stream_name: String, stream: AudioStream):
	added_track_to_music_bank.emit(stream_name, music_bank.get_or_add(stream_name, stream))
	

func remove_stream_from_music_bank(stream_name: String):
	if music_bank.has(stream_name):
		music_bank.erase(stream_name)
		removed_track_from_music_bank.emit(stream_name)


func remove_streams_from_music_bank(stream_names: Array[String]):
	for stream_name: String in stream_names:
		remove_stream_from_music_bank(stream_name)


func _create_audio_stream_players():
	main_audio_stream_player = _create_music_audio_stream_player("MainAudioStreamPlayer")
	secondary_audio_stream_player = _create_music_audio_stream_player("SecondaryAudioStreamPlayer")
	current_audio_stream_player = main_audio_stream_player
	
	add_child(main_audio_stream_player)
	add_child(secondary_audio_stream_player)
	
	main_audio_stream_player.finished.connect(on_finished_audio_stream_player.bind(main_audio_stream_player))
	secondary_audio_stream_player.finished.connect(on_finished_audio_stream_player.bind(secondary_audio_stream_player))


func _create_music_audio_stream_player(player_name: String) -> AudioStreamPlayer:
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.name = player_name
	audio_stream_player.bus = AudioManager.MusicBus
	audio_stream_player.autoplay = false
	
	return audio_stream_player


func _crossfade_tween_is_running() -> bool:
	return crossfade_tween != null and crossfade_tween.is_running()


func on_finished_audio_stream_player(audio_stream_player: AudioStreamPlayer):
	finished_stream.emit(audio_stream_player, audio_stream_player.stream)
