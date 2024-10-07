extends Node


var stream_players_pool: Array[AudioStreamPlayer] = []
var pool_players_number: int = 32:
	set(value):
		pool_players_number = max(2, value)
		setup_pool()


func _ready():
	setup_pool()


func setup_pool():
	for stream_player: AudioStreamPlayer in stream_players_pool.filter(func(audio_player: AudioStreamPlayer): return not audio_player.is_queued_for_deletion()):
		stream_player.queue_free()
	
	stream_players_pool.clear()
	
	
	for i in range(pool_players_number):
		var stream_player = AudioStreamPlayer.new()
		stream_player.name = "PoolAudioStreamPlayer%d" % (i + 1)
		stream_players_pool.append(stream_player)
		add_child(stream_player)


func play(stream: AudioStream, bus: String = "SFX", volume: float = 1.0):
	if _bus_is_valid(bus):
		var available_stream_player = _next_available_stream_player()
		
		if available_stream_player:
			available_stream_player.stream = stream
			available_stream_player.bus = bus
			available_stream_player.volume_db = linear_to_db(volume)
			available_stream_player.play()



func play_with_pitch(stream: AudioStream, bus: String = "SFX", volume: float = 1.0, pitch_scale: float = 1.0):
	if _bus_is_valid(bus):
		var available_stream_player = _next_available_stream_player()
		
		if available_stream_player:
			available_stream_player.stream = stream
			available_stream_player.bus = bus
			available_stream_player.volume_db = linear_to_db(volume)
			available_stream_player.pitch_scale = pitch_scale
			available_stream_player.play()


func play_with_pitch_range(stream: AudioStream, bus: String = "SFX", volume: float = 1.0, min_pitch_scale: float = 0.9, max_pitch_scale: float = 1.3):
	if _bus_is_valid(bus):
		var available_stream_player = _next_available_stream_player()
		
		if available_stream_player:
			play_with_pitch(stream, bus, volume, randf_range(min_pitch_scale, max_pitch_scale))


func play_random_stream(streams: Array[AudioStream] = [], bus: String = "SFX", volume: float = 1.0):
	if streams.is_empty() or not _bus_is_valid(bus):
		return
		
	play(streams.pick_random(), bus, volume)


func play_random_stream_with_pitch(streams: Array[AudioStream] = [], bus: String = "SFX", volume: float = 1.0, pitch_scale: float = 1.0):
	if streams.is_empty() or not _bus_is_valid(bus):
		return
		
	play_with_pitch(streams.pick_random(), bus, volume, pitch_scale)


func play_random_stream_with_pitch_range(streams: Array[AudioStream] = [], bus: String = "SFX", volume: float = 1.0, min_pitch_scale: float = 0.9, max_pitch_scale: float = 1.3):
	if streams.is_empty() or not _bus_is_valid(bus):
		return
		
	play_with_pitch_range(streams.pick_random(), bus, volume, min_pitch_scale, max_pitch_scale)


func stop_streams_from_bus(bus: String = "SFX"):
	
	for player: AudioStreamPlayer in stream_players_pool:
		if player.bus.to_lower() == bus.to_lower():
			player.stop()


func stop_streams_from_buses(buses: Array[String] = ["SFX"]):
	for bus in buses:
		stop_streams_from_bus(bus)


func _bus_is_valid(bus: String) -> bool:
	return AudioServer.get_bus_index(bus) != -1
		

func _next_available_stream_player() -> AudioStreamPlayer:
	var available_players = stream_players_pool.filter(
		func(player: AudioStreamPlayer): 
			return not player.playing and not player.stream_paused
	)
	
	return null if available_players.is_empty() else available_players.front()
