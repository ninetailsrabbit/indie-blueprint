## Original version https://github.com/bitbrain/godot-tutorials/blob/godot-4.x/day-night-cycle/demo/daynightcycle.gd
extends Node

signal time_tick(day: int, hour: int, minute: int)

const MinutesPerDay: int = 1440
const MinutesPerHour: int = 60
const InGameToRealMinuteDuration := TAU / MinutesPerDay

## This value when it's 1.0 means that one minute in real time translates into one second in-game, so modify this value as is needed
@export var in_game_speed: float = 1.0 
@export var initial_day: int = 0
@export_range(0, 59, 1) var initial_minute: int = 0:
	set(minute):
		initial_minute = clamp(minute, 0, MinutesPerHour)
@export_range(0, 23, 1) var initial_hour: int = 12:
	set(hour):
		initial_hour = clamp(hour, 0, 23)
		time = InGameToRealMinuteDuration * MinutesPerHour * initial_hour

var time: float = 0.0
var past_minute: int = -1
## Get the current value time to use on gradient color curves and change the environment tempererature according to the day time
var curve_value: float = 0.0

var current_period: String = "AM"
var current_day: int = 0
var current_hour: int = 0
var current_minute: int = 0


func _ready() -> void:
	set_process(false)
		
	
func _process(delta: float) -> void:
	time += delta * InGameToRealMinuteDuration * in_game_speed
	
	curve_value = (sin(time - PI / 2.0) + 1.0) / 2.0 
	
	_recalculate_time()


func start(day: int = initial_day, hour: int = initial_hour, minute: int = initial_minute) -> void:
	initial_day = day
	initial_hour = hour
	initial_minute = minute
	
	current_day = initial_day
	current_hour = initial_hour
	current_minute = initial_minute
	past_minute = current_minute
	
	time = InGameToRealMinuteDuration * MinutesPerHour * current_hour
	
	set_process(true)


func stop() -> void:
	set_process(false)


func change_day_to(new_day: int) -> void:
	initial_day = new_day


func change_hour_to(new_hour: int) -> void:
	initial_hour = new_hour


func change_minute_to(new_minute: int) -> void:
	initial_minute = new_minute


func _recalculate_time() -> void:
	var total_minutes = int(time / InGameToRealMinuteDuration)
	var current_day_minutes = fmod(total_minutes, MinutesPerDay)
	
	current_day = initial_day + int(total_minutes / MinutesPerDay)
	current_hour = int(current_day_minutes / MinutesPerHour)
	current_minute = initial_minute + int(fmod(current_day_minutes, MinutesPerHour))
	
	if past_minute != current_minute:
		past_minute = current_minute
		
		current_period = "AM" if current_hour < 12 else "PM"
		
		time_tick.emit(current_day, current_hour, current_minute)
