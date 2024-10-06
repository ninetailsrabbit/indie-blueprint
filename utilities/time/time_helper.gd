class_name TimeHelper

enum TimeUnit {
	SECONDS,
	MILLISECONDS,
	MICROSECONDS
}


static var conversions_to_seconds: Dictionary = {
	TimeUnit.SECONDS: 1.0,
	TimeUnit.MILLISECONDS: 1_000.0,
	TimeUnit.MICROSECONDS: 1_000_000.0,
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
static func format_seconds(time: float, use_milliseconds: bool = false) -> String:
	var minutes := floori(time / 60)
	var seconds := fmod(time, 60)
	var milliseconds := fmod(time, 1) * 100

	var result: String = "%02d:%02d" % [minutes, seconds]
	
	if(use_milliseconds):
		result += ":%02d" % milliseconds
		
		
	return result


# Returns the amount of time passed since the engine started
static func get_ticks(time_unit: TimeUnit = TimeUnit.SECONDS) -> float:
	match time_unit:
		TimeUnit.MICROSECONDS:
			return Time.get_ticks_usec()
		TimeUnit.MILLISECONDS:
			return Time.get_ticks_msec()
		TimeUnit.SECONDS:
			return get_ticks_seconds()
		_:
			return get_ticks_seconds()


## Returns the conversion of [method Time.get_ticks_usec] to seconds.
static func get_ticks_seconds() -> float:
	return Time.get_ticks_usec() / conversions_to_seconds[TimeUnit.MICROSECONDS]


static func convert_to_seconds(time: float, origin_unit: TimeUnit) -> float:
	return time / conversions_to_seconds[origin_unit]


static func convert_to(time: float, origin_unit: TimeUnit, target_unit: TimeUnit) -> float:
	return convert_to_seconds(time, origin_unit) * conversions_to_seconds[target_unit]
