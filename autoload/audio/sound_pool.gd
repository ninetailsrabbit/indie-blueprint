extends Node


var stream_players_pool: Array[AudioStreamPlayer] = []
var pool_players_number: int = 32:
	set(value):
		pool_players_number = max(2, value)


func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			pause_streams_from_buses()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			unpause_streams_from_buses()


func _ready():
	increase_pool(pool_players_number)


func increase_pool(pool_number: int, override: bool = false):
	if override:
		for stream_player: AudioStreamPlayer in stream_players_pool.filter(func(audio_player: AudioStreamPlayer): return not audio_player.is_queued_for_deletion()):
			stream_player.queue_free()
		
		stream_players_pool.clear()
	
	var last_index: int = stream_players_pool.size()
	
	for i in range(1, pool_number + 1):
		var stream_player = AudioStreamPlayer.new()
		stream_player.name = "PoolAudioStreamPlayer%d" % (last_index + i)
		stream_players_pool.append(stream_player)
		add_child(stream_player)


func decrease_pool(pool_number: int):
	if stream_players_pool.is_empty():
		return
	elif stream_players_pool.size() == pool_number:
		for stream_player: AudioStreamPlayer in stream_players_pool:
			stream_player.stop()
			stream_player.queue_free()
	else:
		pool_number = clampi(pool_number, 0, stream_players_pool.size())
		
		stream_players_pool.reverse()
		var count: int = 0
		
		while count < pool_number:
			var stream_player: AudioStreamPlayer = stream_players_pool.pop_back()
			stream_player.stop()
			stream_player.queue_free()
			count += 1
			
		stream_players_pool.reverse()
		

func play(stream: AudioStream, volume: float = 1.0, bus: String = AudioManager.SFXBus):
	if _bus_is_valid(bus):
		var available_stream_player = _next_available_stream_player()
		
		if available_stream_player:
			available_stream_player.stream = stream
			available_stream_player.bus = bus
			available_stream_player.volume_db = linear_to_db(volume)
			available_stream_player.play()



func play_with_pitch(stream: AudioStream, volume: float = 1.0, pitch_scale: float = 1.0, bus: String = AudioManager.SFXBus):
	if _bus_is_valid(bus):
		var available_stream_player = _next_available_stream_player()
		
		if available_stream_player:
			available_stream_player.stream = stream
			available_stream_player.bus = bus
			available_stream_player.volume_db = linear_to_db(volume)
			available_stream_player.pitch_scale = pitch_scale
			available_stream_player.play()


func play_with_pitch_range(stream: AudioStream, volume: float = 1.0, min_pitch_scale: float = 0.9, max_pitch_scale: float = 1.3, bus: String = AudioManager.SFXBus):
	if _bus_is_valid(bus):
		var available_stream_player = _next_available_stream_player()
		
		if available_stream_player:
			play_with_pitch(stream, volume, randf_range(min_pitch_scale, max_pitch_scale), bus)


func play_random_stream(streams: Array[AudioStream] = [], volume: float = 1.0, bus: String = AudioManager.SFXBus):
	if streams.is_empty() or not _bus_is_valid(bus):
		return
		
	play(streams.pick_random(), volume, bus)


func play_random_stream_with_pitch(streams: Array[AudioStream] = [], volume: float = 1.0, pitch_scale: float = 1.0, bus: String = AudioManager.SFXBus):
	if streams.is_empty() or not _bus_is_valid(bus):
		return
		
	play_with_pitch(streams.pick_random(), volume, pitch_scale, bus)


func play_random_stream_with_pitch_range(streams: Array[AudioStream] = [], volume: float = 1.0, min_pitch_scale: float = 0.9, max_pitch_scale: float = 1.3,  bus: String = AudioManager.SFXBus):
	if streams.is_empty() or not _bus_is_valid(bus):
		return
		
	play_with_pitch_range(streams.pick_random(), volume, min_pitch_scale, max_pitch_scale, bus)


func stop_streams_from_bus(bus: String = AudioManager.SFXBus):
	for player: AudioStreamPlayer in stream_players_pool:
		if player.bus.to_lower() == bus.to_lower():
			player.stop()


func stop_streams_from_buses(buses: Array[String] = [AudioManager.SFXBus]):
	for bus in buses:
		stop_streams_from_bus(bus)


func pause_streams_from_bus(bus: String = AudioManager.SFXBus):
	for player: AudioStreamPlayer in stream_players_pool:
		if player.bus.to_lower() == bus.to_lower():
			player.stream_paused = true


func pause_streams_from_buses(buses: Array[String] = [AudioManager.SFXBus]):
	for bus in buses:
		pause_streams_from_bus(bus)


func unpause_streams_from_bus(bus: String = AudioManager.SFXBus):
	for player: AudioStreamPlayer in stream_players_pool:
		if player.bus.to_lower() == bus.to_lower():
			player.stream_paused = false


func unpause_streams_from_buses(buses: Array[String] = [AudioManager.SFXBus]):
	for bus in buses:
		unpause_streams_from_bus(bus)


func _bus_is_valid(bus: String) -> bool:
	return AudioServer.get_bus_index(bus) != -1
		

func _next_available_stream_player() -> AudioStreamPlayer:
	var available_players = stream_players_pool.filter(
		func(player: AudioStreamPlayer): 
			return not player.playing and not player.stream_paused
	)
	
	return null if available_players.is_empty() else available_players.front()
