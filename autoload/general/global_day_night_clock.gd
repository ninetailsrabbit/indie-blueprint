## Original version https://github.com/bitbrain/godot-tutorials/blob/godot-4.x/day-night-cycle/demo/daynightcycle.gd
extends Node

signal time_tick(day: int, hour: int, minute: int)
signal hour_passed
signal day_passed

const MinutesPerDay: int = 1440 
const MinutesPerHour: int = 60
@warning_ignore("integer_division")
const DayHourLength: int = MinutesPerDay / MinutesPerHour
const InGameToRealMinuteDuration := TAU / MinutesPerDay

@export var emit_tick_signal: bool = false
## This value when it's 1.0 means that one minute in real time translates into one second in-game, so modify this value as is needed
@export var in_game_speed: float = 1.0 
@export var initial_day: int = 0
@export_range(0, 59, 1) var initial_minute: int = 0:
	set(minute):
		initial_minute = clampi(minute, 0, MinutesPerHour)
@export_range(0, 23, 1) var initial_hour: int = 12:
	set(hour):
		initial_hour = clampi(hour, 0, 23)
		time = InGameToRealMinuteDuration * MinutesPerHour * initial_hour

var is_running: bool = false
var time: float = 0.0
var past_minute: int = -1
## Get the current value time to use on gradient color curves and change the environment tempererature according to the day time
var curve_value: float = 0.0:
	set(value):
		if value != curve_value:
			curve_value = clampf(value, 0.0, 1.0)
var current_period: String = "AM"
var current_day: int = 0:
	set(value):
		if value != current_day:
			current_day = maxi(0, value)
			day_passed.emit()
var current_hour: int = 0:
	set(value):
		if value != current_hour:
			current_hour = value
			current_hour = clampi(value, 0, 23)
			hour_passed.emit()
var current_minute: int = 0:
	set(value):
		if value != current_minute:
			current_minute = value
			current_minute = clampi(value, 0, 59)

func _ready() -> void:
	set_process(false)
	

func _process(delta: float) -> void:
	time += delta * InGameToRealMinuteDuration * in_game_speed
	_recalculate_time()
	
	curve_value = get_curve_value()
	
	if curve_value >= 1.0:
		curve_value = 0.0


func start(day: int = initial_day, hour: int = initial_hour, minute: int = initial_minute) -> void:
	initial_day = day
	initial_hour = hour
	initial_minute = minute
	
	current_day = initial_day
	current_hour = initial_hour
	current_minute = initial_minute
	past_minute = current_minute
	
	time = InGameToRealMinuteDuration * MinutesPerHour * current_hour
	
	is_running = true
	set_process(true)


func stop() -> void:
	is_running = false
	set_process(false)


func total_seconds() -> int:
	if current_day > 0:
		return current_day * seconds()
	
	return seconds()


func seconds(hour: int = current_hour, minute: int = current_minute) -> int:
	return (hour * MinutesPerHour * MinutesPerHour) + minute * MinutesPerHour


func get_curve_value(hour: int = current_hour, minute: int = current_minute) -> float:
	var current_time_fraction = (seconds(hour, minute) * 1000) / (DayHourLength * MinutesPerHour * MinutesPerHour * 1000.0)
	

	return clampf(current_time_fraction, 0.0, 1.0)


func time_display() -> String:
	var hour: int = current_hour
	var minute: int = current_minute

	if hour < 10:
		return "0" + str(hour)
		
	if minute < 10:
		return "0" + str(minute)

	return "%s:%s" % [hour, minute]


func change_day_to(new_day: int) -> void:
	initial_day = new_day


func change_hour_to(new_hour: int) -> void:
	initial_hour = new_hour


func change_minute_to(new_minute: int) -> void:
	initial_minute = new_minute


func is_am() -> bool:
	return current_period == "AM"


func is_pm() -> bool:
	return current_period == "PM"
	
@warning_ignore("integer_division")
func _recalculate_time() -> void:
	var total_minutes = int(time / InGameToRealMinuteDuration) + initial_minute
	var current_day_minutes = fmod(total_minutes, MinutesPerDay) + initial_minute
	
	current_day = initial_day + int(total_minutes / MinutesPerDay)
	current_hour = int(current_day_minutes / MinutesPerHour)
	current_minute = int(fmod(current_day_minutes, MinutesPerHour))
	
	if past_minute != current_minute:
		past_minute = current_minute
		
		current_period = "AM" if current_hour < 12 else "PM"
		
		if emit_tick_signal:
			time_tick.emit(current_day, current_hour, current_minute)
