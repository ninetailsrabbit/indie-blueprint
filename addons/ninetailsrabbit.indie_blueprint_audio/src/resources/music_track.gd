class_name MusicTrack extends Resource

@export var track_name: StringName
@export var artist: StringName
@export var stream: AudioStream
@export var bus: StringName = &"Music"


func _init(_stream: AudioStream, _name: StringName, _artist: StringName, _bus: StringName) -> void:
	stream = _stream
	track_name = _name
	artist = _artist
	bus = _bus
