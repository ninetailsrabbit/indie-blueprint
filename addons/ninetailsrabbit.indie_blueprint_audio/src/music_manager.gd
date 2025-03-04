extends Node

const VolumeDBInaudible: float = -80.0

signal changed_play_mode(new_mode: PlayMode)

signal added_track_to_music_bank(track: MusicTrack)
signal removed_track_from_music_bank(track: MusicTrack)

signal changed_track(from: MusicTrack, to: MusicTrack)
signal started_track(new_track: MusicTrack)
signal finished_track(track: MusicTrack)

signal created_playlist(playlist: MusicPlaylist)
signal removed_playlist(playlist: MusicPlaylist)
signal changed_playlist(from: MusicPlaylist, to: MusicPlaylist)
signal started_playlist(playlist: MusicPlaylist)
signal finished_playlist(playlist: MusicPlaylist)


enum PlayMode {
	## The music tracks are manually initiated
	Manual,
	## Once a stream ends, get another random stream from the music bank.
	RandomMusicFromBank,
	## Uses a playlist provided in which songs are played sequentially.
	Playlist
}

var music_bank: Array[MusicTrack] = []
## Dictionary<String, MusicPlaylist>
var music_playlists: Dictionary = {}

#region AudioStreamPlayers
var main_audio_stream_player: AudioStreamPlayer
var secondary_audio_stream_player: AudioStreamPlayer
var current_audio_stream_player: AudioStreamPlayer
#endregion

#region Crossfade
var crossfade_tween: Tween
var default_crossfade_time: float = 5.0
#endregion

var current_track: MusicTrack
var current_playlist: MusicPlaylist
var current_mode: PlayMode = PlayMode.Manual:
	set(new_mode):
		if new_mode != current_mode:
			current_mode = new_mode
			changed_play_mode.emit(current_mode)


func _ready():
	if get_tree().root.has_node(IndieBlueprintAudioSettings.AudioManagerSingleton):
		_create_audio_stream_players(get_tree().root.get_node(IndieBlueprintAudioSettings.AudioManagerSingleton).MusicBus)
	
#region Play mode
func change_mode_to_manual() -> void:
	change_mode(PlayMode.Manual)


func change_mode_to_random_music_from_bank() -> void:
	change_mode(PlayMode.RandomMusicFromBank)


func change_mode_to_playlist() -> void:
	change_mode(PlayMode.Playlist)


func change_mode(new_play_mode: PlayMode) -> void:
	current_mode = new_play_mode


func is_manual_mode() -> bool:
	return current_mode == PlayMode.Manual
	

func is_random_music_mode() -> bool:
	return current_mode == PlayMode.RandomMusicFromBank
	
	
func is_playlist_mode() -> bool:
	return current_mode == PlayMode.Playlist


#endregion

func start_playlist(playlist, from_track: int = 0, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	var next_playlist: MusicPlaylist
	var playlist_name: String = ""
	
	if typeof(playlist) == TYPE_STRING or typeof(playlist) == TYPE_STRING_NAME:
		next_playlist = music_playlists.get(playlist)
		playlist_name = playlist

	elif playlist is MusicPlaylist:
		next_playlist = playlist
		playlist_name = playlist.playlist_name
	
	if next_playlist == null:
		push_error("MusicManager: The playlist with the name %s does not exist" % playlist_name)
		return
	
	if current_playlist != null and current_playlist != next_playlist:
		changed_playlist.emit(current_playlist, next_playlist)
		
	current_playlist = next_playlist
	
	_play_music_track(next_playlist.tracks[from_track], crossfade, crossfade_time)
	
	started_playlist.emit(current_playlist)

		
func play_music_from_bank(track, crossfade: bool = true, crossfade_time: float = default_crossfade_time):
	var next_track: MusicTrack
	var track_name: String = ""
	
	if typeof(track) == TYPE_STRING or typeof(track) == TYPE_STRING_NAME:
		next_track = get_music_from_bank(track)
		track_name = track
	
	elif track is MusicTrack:
		next_track = track
		track_name = track.track_name

	if next_track == null:
		push_error("MusicManager: Expected music name %s to exists in the MusicBank but no stream was found" % track_name)
		return

	_play_music_track(next_track, crossfade, crossfade_time)


func get_music_from_bank(track_name: StringName) -> MusicTrack:
	var tracks: Array[MusicTrack] = music_bank.filter(
		func(music_track: MusicTrack): return music_track.track_name == track_name
		)
	
	if tracks.is_empty():
		return null
		
	return tracks.front()


func _play_music_track(track: MusicTrack, crossfade: bool = true, crossfade_time: float = default_crossfade_time):
	if _crossfade_tween_is_running():
		return
		
	if current_audio_stream_player.stream != null:
		changed_track.emit(current_track, track)
	
	if current_audio_stream_player.is_playing() and crossfade:
		var next_audio_stream_player: AudioStreamPlayer = secondary_audio_stream_player if current_audio_stream_player == main_audio_stream_player else main_audio_stream_player
		next_audio_stream_player.volume_db = VolumeDBInaudible
	
		next_audio_stream_player.stop()
		next_audio_stream_player.bus = track.bus
		next_audio_stream_player.stream = track.stream
		next_audio_stream_player.play()

		var volume: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(next_audio_stream_player.bus))
		
		crossfade_tween = create_tween().set_parallel(true)
		crossfade_tween.tween_property(current_audio_stream_player, "volume_db", VolumeDBInaudible, crossfade_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
		crossfade_tween.tween_property(next_audio_stream_player, "volume_db", volume, crossfade_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
		crossfade_tween.chain().tween_callback(func(): 
			current_audio_stream_player.stop()
			current_audio_stream_player = next_audio_stream_player
			current_track = track
			)
	else:
		current_audio_stream_player.stop()
		current_audio_stream_player.bus = track.bus
		current_audio_stream_player.stream = track.stream
		current_audio_stream_player.play()
		current_track = track
		
	started_track.emit(track)
	
	
func pause_current_track() -> void:
	if current_audio_stream_player.stream != null and not current_audio_stream_player.stream_paused:
		current_audio_stream_player.stream_paused = true


func replay_current_track() -> void:
	if current_audio_stream_player.stream != null and current_audio_stream_player.stream_paused:
		current_audio_stream_player.play()
	

#region Music bank
func pick_random_track_from_bank(except: Array[MusicTrack]= []) -> MusicTrack:
	var tracks: Array[MusicTrack] = music_bank.filter(func(track: MusicTrack): return not track in except)
		
	if tracks.size() > 0:
		return tracks.pick_random()
		
	return null


func add_music_tracks_to_bank(tracks: Array[MusicTrack]):
	for track: MusicTrack in tracks:
		add_music_track_to_bank(track)


func add_music_track_to_bank(track: MusicTrack):
	music_bank.append(track)
	added_track_to_music_bank.emit(track)
	

func remove_track_from_bank(track: MusicTrack):
		music_bank.erase(track)
		removed_track_from_music_bank.emit(track)


func remove_tracks_from_bank(tracks: Array[MusicTrack]):
	for track: MusicTrack in tracks:
		remove_track_from_bank(track)
#endregion


#region Playlists
func add_playlist(playlist: MusicPlaylist) -> void:
	music_playlists.get_or_add(playlist.playlist_name, playlist)
	created_playlist.emit(playlist)


func remove_playlist(playlist) -> void:
	if typeof(playlist) == TYPE_STRING or typeof(playlist) == TYPE_STRING_NAME:
		
		if music_playlists.has(playlist):
			removed_playlist.emit(music_playlists[playlist])
			music_playlists.erase(playlist)
			
	elif playlist is MusicPlaylist:
		if music_playlists.has(playlist.playlist_name):
			removed_playlist.emit(playlist)
			music_playlists.erase(playlist.playlist_name)


func play_next_in_playlist(playlist: MusicPlaylist = current_playlist) -> void:
	if playlist:
		if playlist.tracks.back() == current_track:
			finished_playlist.emit(playlist)
			
		_play_music_track(next_in_playlist(playlist))


func next_in_playlist(playlist: MusicPlaylist = current_playlist) -> MusicTrack:
	var playlist_tracks: Array[MusicTrack] = playlist.tracks
	
	if playlist_tracks.size() > 0:
		if current_track:
			var index: int = playlist_tracks.find(current_track)
			
			if index != -1 and index + 1 < playlist_tracks.size():
				return playlist_tracks[index + 1]
		
		return playlist.tracks.front()
	
	return null

#endregion


#region Syntatic sugar to play a music a track
func change_track_to(new_stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	play_music_from_bank(new_stream_name, crossfade, crossfade_time)


func change_track(new_stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	play_music_from_bank(new_stream_name, crossfade, crossfade_time)


func change_music(new_stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	play_music_from_bank(new_stream_name, crossfade, crossfade_time)


func change_music_to(new_stream_name: String, crossfade: bool = true, crossfade_time: float = default_crossfade_time) -> void:
	play_music_from_bank(new_stream_name, crossfade, crossfade_time)
#endregion

#region Private helpers
func _create_audio_stream_players(bus: StringName):
	main_audio_stream_player = _create_music_audio_stream_player("MainAudioStreamPlayer", bus)
	secondary_audio_stream_player = _create_music_audio_stream_player("SecondaryAudioStreamPlayer", bus)
	current_audio_stream_player = main_audio_stream_player
	
	add_child(main_audio_stream_player)
	add_child(secondary_audio_stream_player)
	
	main_audio_stream_player.finished.connect(on_finished_audio_stream_player.bind(main_audio_stream_player))
	secondary_audio_stream_player.finished.connect(on_finished_audio_stream_player.bind(secondary_audio_stream_player))


func _create_music_audio_stream_player(player_name: String, bus: StringName) -> AudioStreamPlayer:
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.name = player_name
	audio_stream_player.bus = bus
	audio_stream_player.autoplay = false
	
	return audio_stream_player


func _crossfade_tween_is_running() -> bool:
	return crossfade_tween != null and crossfade_tween.is_running()

#endregion

#region Signal callbacks
func on_finished_audio_stream_player(_audio_stream_player: AudioStreamPlayer):
	finished_track.emit(current_track)
	
	if is_random_music_mode() and music_bank.size() > 1:
		play_music_from_bank(pick_random_track_from_bank([current_track] if current_track else []))
	elif is_playlist_mode():
		play_next_in_playlist()
#endregion
