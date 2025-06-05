## Inspired by the original version https://github.com/bitbrain/godot-tutorials/blob/godot-4.x/day-night-cycle/demo/daynightcycle.gd
extends Node

signal time_tick(day: int, hour: int, minute: int)
signal hour_passed
signal day_passed

const MinutesPerDay: float = 1440.0
const HoursPerDay: float = 24.0
const MinutesPerHour: float = 60.0
@warning_ignore("integer_division")
const DayHourLength: int = MinutesPerDay / MinutesPerHour

@export var real_life_seconds_to_game_minute: float = 5.0:
	set(value):
		if value != real_life_seconds_to_game_minute:
			real_life_seconds_to_game_minute = maxf(0.1, value)
			_update_time_rate()
			
## Translated seconds into real life minute. This means that each 5 seconds a minute pass in the game.
@export var start_day: int = 0
@export_range(0, 23, 1) var start_hour: int = 0
@export_range(0, 59, 1) var start_minute: int = 0

var current_day: int = 0:
	set(value):
		current_day = maxi(0, value)
		day_passed.emit()

var current_hour: int = 0:
	set(value):
		@warning_ignore("narrowing_conversion")
		current_hour = clampi(value, 0, HoursPerDay - 1)
var current_minute: int = 0:
	set(value):
		@warning_ignore("narrowing_conversion")
		current_minute = clampi(value, 0, MinutesPerHour - 1)

var time: float = 0.0:
	set(value):
		time = clampf(value, 0.0, 1.0)
		
var time_rate: float = 0.0


func _ready() -> void:
	start(start_day, start_hour, start_minute)
	

func _process(delta: float) -> void:
	time += time_rate * delta
		
	if time >= 1.0:
		time = 0.0
	
	var total_minutes_in_day = time * MinutesPerDay

	var hour: int = floor(total_minutes_in_day / MinutesPerHour)
	var minute: int = fmod(total_minutes_in_day, MinutesPerHour)
	
	if round(minute) >= MinutesPerHour:
		minute = 0
		hour += 1
	
	if hour >= HoursPerDay:
		hour = 0
	
	if current_hour == 23 and hour == 0:
		update_day(current_day + 1)
	elif current_hour == 0 and hour == 23:
		update_day(current_day - 1)
		
	update_current_time(hour, minute)


func update_current_time(hour: int, minute: int) -> void:
	current_hour = hour
	current_minute = minute


func update_day(day: int) -> void:
	current_day = day
	

func start(day: int = current_day, hour: int = current_hour, minute: int = current_minute) -> void:
	update_day(day)
	update_current_time(hour, minute)
	_update_time_sampler()
	call_deferred("set_process", true)
	
	
func stop() -> void:
	set_process(false)


func total_seconds() -> int:
	if current_day > 0:
		return current_day * seconds()
	
	return seconds()


func seconds(hour: int = current_hour, minute: int = current_minute) -> int:
	return (hour * MinutesPerHour * MinutesPerHour) + minute * MinutesPerHour


func time_display(hour: int = current_hour, minute: int = current_minute) -> String:
	var hour_str: String = str(hour)
	var minute_str: String = str(minute)
	
	if hour < 10:
		hour_str = "0" + str(hour)
		
	if minute < 10:
		minute_str = "0" + str(minute)
	
	return "%s:%s" % [hour_str, minute_str] 


func is_am() -> bool:
	return current_hour < 12


func is_pm() -> bool:
	return current_hour >= 12


func _update_time_rate(seconds_per_minute: float = real_life_seconds_to_game_minute) -> void:
	time_rate = 1.0 / (MinutesPerDay * seconds_per_minute)


func _update_time_sampler(hour: int = current_hour, minute: int = current_minute) -> void:
	time = (current_hour + (current_minute / MinutesPerHour)) / HoursPerDay
