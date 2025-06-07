@tool
class_name DayNightCycle extends Node

signal changed_day_zone(previous_zone: DayZone, new_zone: DayZone)

const MinutesPerDay: float = 1440.0
const HoursPerDay: float = 24.0
const MinutesPerHour: float = 60.0

@export var world_environment: WorldEnvironment
@export var sun: DirectionalLight3D
@export_category("Time")
## Translated seconds into real life minute. This means that each 5 seconds a minute pass in the game.
@export var real_life_seconds_to_game_minute: float = 5.0:
	set(value):
		if value != real_life_seconds_to_game_minute:
			real_life_seconds_to_game_minute = maxf(0.1, value)
			_update_time_rate()
@export_range(0, 23, 1) var start_hour: int = 0
@export_range(0, 59, 1) var start_minute: int = 0
@export_category("Zone hours")
@export_range(0, 23, 1, "hour") var dawn_hour: int = 6
@export_range(0, 23, 1) var day_hour: int = 12
@export_range(0, 23, 1) var dusk_hour: int = 19
@export_range(0, 23, 1) var night_hour: int = 22
@export_category("Sun")
## Curve where "x" value is the hour of the day and "Y" the sun light energy
@export var sun_intensity: Curve
## Gradient 
@export var sun_gradient: Gradient
@export_category("Sky")
@export var sky_top_color_gradient: Gradient
@export var sky_horizon_color_gradient: Gradient 
@export var sky_ground_horizon_color_gradient: Gradient
@export var sky_ground_bottom_color_gradient: Gradient
@export var sky_clouds_color_gradient: Gradient


enum DayZone {
	Dawn,
	Day,
	Dusk,
	Night
}

var current_hour: int = 0:
	set(value):
		@warning_ignore("narrowing_conversion")
		current_hour = clampi(value, 0, HoursPerDay - 1)
var current_minute: int = 0:
	set(value):
		@warning_ignore("narrowing_conversion")
		current_minute = clampi(value, 0, MinutesPerHour - 1)
var current_day_zone: DayZone = DayZone.Day

var time: float = 0.0:
	set(value):
		time = clampf(value, 0.0, 1.0)
var time_rate: float = 0.0


func _ready() -> void:
	set_process(false)
	
	_update_time_rate()
	update_current_time(start_hour, start_minute)
	_update_time_sampler()
	call_deferred("set_process", true)


func _process(delta: float) -> void:
	time += time_rate * delta
		
	if time >= 1.0:
		time = 0.0
	
	var total_minutes_in_day = time * MinutesPerDay

	var hour = floor(total_minutes_in_day / MinutesPerHour)
	var minute = fmod(total_minutes_in_day, MinutesPerHour)
	
	if round(minute) >= MinutesPerHour:
		minute = 0
		hour += 1

	if hour >= HoursPerDay:
		hour = 0
	
	update_current_time(hour, minute)
	

func _update_time_rate(seconds_per_minute: float = real_life_seconds_to_game_minute) -> void:
	time_rate = 1.0 / (MinutesPerDay * seconds_per_minute)


func _update_time_sampler(hour: int = current_hour, minute: int = current_minute) -> void:
	time = (hour + (minute / MinutesPerHour)) / HoursPerDay
		

func start(hour: int = current_hour, minute: int = current_minute) -> void:
	update_current_time(hour, minute)
	_update_time_sampler()
	call_deferred("set_process", true)


func stop() -> void:
	set_process(false)


func update_current_time(hour: int, minute: int) -> void:
	current_hour = hour
	current_minute = minute
	
	update_day_zone()
	update_sun()
	update_sky()


func update_sun(hour: int = current_hour, minute: int = current_minute) -> void:
	if sun:
		var current_time: float = hour + (minute / MinutesPerHour)
		
		if sun_intensity:
			sun.light_energy = sun_intensity.sample(current_time)
		
		if sun_gradient:
			sun.light_color = sun_gradient.sample(current_time / HoursPerDay)
		
		## We increase here the maximum hour to extend the visibility of the sun in the horizon
		## With default values, the sunset happens more or less at 18:30, just increase the maximum hour
		## to extend the sun visibility during the day (25.0 instead of 23.59)
		sun.rotation_degrees.x = (current_time / 25.0) * 360.0 + 90.0


func update_sky(hour: int = current_hour, minute: int = current_minute) -> void:
	var sky: Sky = world_environment.environment.sky
	var sky_material: ShaderMaterial = world_environment.environment.sky.sky_material
	var current_time: float = hour + (minute / MinutesPerHour)
	var time_sample: float = current_time / HoursPerDay
	
	if sky_material:
		if sky_top_color_gradient:
			sky_material.set_shader_parameter("sky_top_color", sky_top_color_gradient.sample(time_sample))
		
		if sky_horizon_color_gradient:
			sky_material.set_shader_parameter("sky_horizon_color", sky_horizon_color_gradient.sample(time_sample))
		
		if sky_ground_horizon_color_gradient:
			sky_material.set_shader_parameter("ground_horizon_color", sky_ground_horizon_color_gradient.sample(time_sample))

		if sky_ground_bottom_color_gradient:
			sky_material.set_shader_parameter("ground_bottom_color", sky_ground_bottom_color_gradient.sample(time_sample))
	
		if sky_clouds_color_gradient:
			sky_material.set_shader_parameter("sky_cover_modulate", sky_clouds_color_gradient.sample(time_sample))
	
	
func update_day_zone(hour: int = current_hour) -> void:
	if not is_dawn() and hour >= dawn_hour and hour < day_hour:
		current_day_zone = DayZone.Dawn
		changed_day_zone.emit(DayZone.Night, DayZone.Dawn)
		
	elif not is_day() and hour >= day_hour and hour < dusk_hour:
		current_day_zone = DayZone.Day
		changed_day_zone.emit(DayZone.Night, DayZone.Day)
		
	elif not is_dusk() and hour >= dusk_hour and hour < night_hour:
		current_day_zone = DayZone.Dusk
		changed_day_zone.emit(DayZone.Day, DayZone.Dusk)
		
	elif not is_night() and hour >= night_hour and hour <= 23:
		current_day_zone = DayZone.Night
		changed_day_zone.emit(DayZone.Dusk, DayZone.Night)

func is_dawn() -> bool:
	return current_day_zone == DayZone.Dawn;

func is_day() -> bool:
	return current_day_zone == DayZone.Day;
	
func is_dusk() -> bool:
	return current_day_zone == DayZone.Dusk;
	
func is_night() -> bool:
	return current_day_zone == DayZone.Night;
