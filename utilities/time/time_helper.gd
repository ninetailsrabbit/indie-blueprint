class_name TimeHelper

enum TimeUnit {
	Seconds,
	Milliseconds,
	Microseconds
}


static var conversions_to_seconds: Dictionary = {
	TimeUnit.Seconds: 1.0,
	TimeUnit.Milliseconds: 1_000.0,
	TimeUnit.Microseconds: 1_000_000.0,
}

"""
Formats a time value into a string representation of minutes, seconds, and optionally milliseconds.

Args:
	time (float): The time value to format, in seconds.
	use_milliseconds (bool, optional): Whether to include milliseconds in the formatted string. Defaults to false.

Returns:
	str: A string representation of the formatted time in the format "MM:SS" or "MM:SS:mm", depending on the value of use_milliseconds.

Example:
	# Format 123.456 seconds without milliseconds
	var formatted_time = format_seconds(123.456)
	# Result: "02:03"

	# Format 123.456 seconds with milliseconds
	var formatted_time_with_ms = format_seconds(123.456, true)
	# Result: "02:03:45"
"""
@warning_ignore("narrowing_conversion")
static func format_seconds(time: float, use_milliseconds: bool = false) -> String:
	var minutes: int= floori(time / 60)
	var seconds: int = fmod(time, 60)
	var milliseconds: int = fmod(time, 1) * 100

	var result: String = "%02d:%02d" % [minutes, seconds]
	
	if(use_milliseconds):
		result += ":%02d" % milliseconds
		
	return result


# Returns the amount of time passed since the engine started
static func get_ticks(time_unit: TimeUnit = TimeUnit.Seconds) -> float:
	match time_unit:
		TimeUnit.Microseconds:
			return Time.get_ticks_usec()
		TimeUnit.Milliseconds:
			return Time.get_ticks_msec()
		TimeUnit.Seconds:
			return get_ticks_seconds()
		_:
			return get_ticks_seconds()


## Returns the conversion of [method Time.get_ticks_usec] to seconds.
static func get_ticks_seconds() -> float:
	return Time.get_ticks_usec() / conversions_to_seconds[TimeUnit.Microseconds]


static func convert_to_seconds(time: float, origin_unit: TimeUnit) -> float:
	return time / conversions_to_seconds[origin_unit]


static func convert_to(time: float, origin_unit: TimeUnit, target_unit: TimeUnit) -> float:
	return convert_to_seconds(time, origin_unit) * conversions_to_seconds[target_unit]


static func create_idle_timer(wait_time: float = 1.0, autostart: bool = false, one_shot: bool = false) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.process_callback = Timer.TIMER_PROCESS_IDLE
	timer.autostart = autostart
	timer.one_shot = one_shot
	
	return timer


static func create_physics_timer(wait_time: float = 1.0, autostart: bool = false, one_shot: bool = false) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.autostart = autostart
	timer.one_shot = one_shot
	
	return timer
