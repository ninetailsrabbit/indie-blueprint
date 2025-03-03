class_name MusicPlaylist extends Resource

@export var playlist_name: StringName
@export var tracks: Array[MusicTrack] = []


func _init(_name: StringName, _tracks: Array[MusicTrack]) -> void:
	playlist_name = _name
	tracks = _tracks
