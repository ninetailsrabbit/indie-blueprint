@tool
class_name DayNightCycle extends Node

const DawnZone: StringName = &"dawn"
const DayZone: StringName = &"day"
const DuskZone: StringName = &"dusk"
const NightZone: StringName = &"night"


signal changed_day_zone(previous_zone: StringName, new_zone: StringName)


@export var world_environment: WorldEnvironment
@export var sun: DirectionalLight3D
@export var moon: DirectionalLight3D
@export var use_global_day_night_clock: bool = true:
	set(value):
		if value != use_global_day_night_clock:
			use_global_day_night_clock = value
			notify_property_list_changed()
			_connect_to_global_day_night_clock()
			
			if not use_global_day_night_clock:
				time_rate = 1.0 / day_length
				time = start_time
				
@export_category("Time")
@export var day_length: float = 15.0:
	set(value):
		if value != day_length:
			day_length = maxf(0.5, value)
			time_rate = 1.0 / day_length
## This is a percent between 0.0 and 1.0 where 0.5 means is 12:00 
@export_range(0.0, 1.0, 0.01) var start_time: float = 0.3

@export_category("Sun")
@export var sun_base_light_energy: float = 0.2
@export_range(0.0, 1.0, 0.01) var min_sun_disc_size: float = 0.1
@export_range(0.0, 1.0, 0.01) var max_sun_disc_size: float = 1.0
@export var sun_color: Gradient = preload("res://components/environment/day_night_cycle/sun_gradients/normal/normal_sun_color_gradient.tres")
@export var sun_intensity: Curve = preload("res://components/environment/day_night_cycle/sun_gradients/normal/normal_sun_intensity_curve.tres")
@export var sun_change_rotation_on_new_day: bool = true:
	set(value):
		if value != sun_change_rotation_on_new_day:
			sun_change_rotation_on_new_day = value
			notify_property_list_changed()
@export var sun_change_rotation_amount: Vector3 = Vector3(0, 3.0, 4.0)
@export_category("Moon")
@export var moon_base_light_energy: float = 0.25
@export var moon_color: Gradient = preload("res://components/environment/day_night_cycle/moon_gradients/normal/normal_moon_color_gradient.tres")
@export var moon_intensity: Curve = preload("res://components/environment/day_night_cycle/moon_gradients/normal/normal_moon_intensity_curve.tres")
@export var moon_change_rotation_on_new_day: bool = true:
	set(value):
		if value != moon_change_rotation_on_new_day:
			moon_change_rotation_on_new_day = value
			notify_property_list_changed()
@export var moon_change_rotation_amount: Vector3 = Vector3(0, 3.5, 2.5)
@export_category("Sky")
@export var dawn_hour: int = 6
@export var day_hour: int = 12
@export var dusk_hour: int = 19
@export var night_hour: int = 21
@export var available_day_panoramas: Array[Texture2D] = []
@export var available_dusk_panoramas: Array[Texture2D] = []
@export var overcast_panoramas: Array[Texture2D] = []

@export var sky_top_color: Gradient = preload("res://components/environment/day_night_cycle/sky_color_gradients/normal/normal_sky_top_color_gradient.tres")
@export var sky_horizon_color: Gradient = preload("res://components/environment/day_night_cycle/sky_color_gradients/normal/normal_sky_horizon_gradient.tres")
@export var sky_ground_color: Gradient = preload("res://components/environment/day_night_cycle/sky_color_gradients/normal/normal_sky_ground_gradient.tres")

## Use time to get sample values from a curve, left to right, 0 represents the start of day and 1.0 the night
var time: float = 0.0
var previous_time: float = 0.0
## How we're going to increase time per second. 
## High day_lenght values results in lower time rate and viceversa
var time_rate: float
var current_day_zone: StringName = DawnZone


func _validate_property(property: Dictionary):
	if property.name in ["day_length", "start_time"]:
		property.usage = PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR if use_global_day_night_clock else PROPERTY_USAGE_EDITOR
	
	if property.name in ["sun_change_rotation_amount"]:
		property.usage = PROPERTY_USAGE_EDITOR if sun_change_rotation_on_new_day else PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR
	
	if property.name in ["moon_change_rotation_amount"]:
		property.usage = PROPERTY_USAGE_EDITOR if moon_change_rotation_on_new_day else PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if use_global_day_night_clock:
		_connect_to_global_day_night_clock()
		
		if IndieBlueprintGlobalClock.is_am():
			adjust_day_panorama()
		else:
			adjust_panorama_based_on_hour()
	else:
		time_rate = 1.0 / day_length
		time = start_time
		

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	previous_time = time
	
	if Engine.get_process_frames() % 5 == 0:
		if use_global_day_night_clock:
			if IndieBlueprintGlobalClock.is_running:
				time = IndieBlueprintGlobalClock.curve_value
		else:
			time += time_rate * delta
		
			if time >= 1.0:
				time = 0.0
		
		sun.visible = sun_visible()
		moon.visible = moon_visible()
		
		if previous_time == 0 and time > 0:
			sun.rotation_degrees.x = time * 360.0 + 90.0
			moon.rotation_degrees.x = time * 360.0 + 270.0
		else:
			sun.rotation_degrees.x = lerp(sun.rotation_degrees.x, time * 360.0 + 90.0, 15 * delta)
			moon.rotation_degrees.x = lerp(moon.rotation_degrees.x, time * 360.0 + 270.0, 15 * delta)
		
		sun.light_color = sun_color.sample(time)
		sun.light_energy = sun_base_light_energy + sun_intensity.sample(time)
		
		moon.light_color = moon_color.sample(time)
		moon.light_energy = moon_base_light_energy + moon_intensity.sample(time)
		
		var sky_material: ShaderMaterial = world_environment.environment.sky.sky_material
		
		if sky_material:
			sky_material.set_shader_parameter("sun", sun.visible)
			sky_material.set_shader_parameter("sun_color", sun.light_color)
			sky_material.set_shader_parameter("sun_blur", time)
			sky_material.set_shader_parameter("sun_disc", clampf(time, min_sun_disc_size, max_sun_disc_size))
			sky_material.set_shader_parameter("sky_color", sky_top_color.sample(time))
			sky_material.set_shader_parameter("horizon_color", sky_horizon_color.sample(time))
			sky_material.set_shader_parameter("ground_color", sky_ground_color.sample(time))


func sun_visible() -> bool:
	if use_global_day_night_clock:
		return (is_dawn() or is_day()) and not ((IndieBlueprintGlobalClock.current_hour >= 18 and IndieBlueprintGlobalClock.current_minute >= 10))
	
	return sun.light_energy > 0
	

func moon_visible() -> bool:
	return is_night() if use_global_day_night_clock else moon.light_energy > 0
	 
## Curve is 0.25 when start dawn
func is_dawn() -> bool:
	if use_global_day_night_clock:
		return IndieBlueprintMathHelper.value_is_between(IndieBlueprintGlobalClock.current_hour, dawn_hour, day_hour - 1)
	
	return false


func is_day() -> bool:
	if use_global_day_night_clock:
		return IndieBlueprintMathHelper.value_is_between(IndieBlueprintGlobalClock.current_hour, day_hour, dusk_hour - 1)
	
	return false
	

func is_dusk() -> bool:
	if use_global_day_night_clock:
		return IndieBlueprintMathHelper.value_is_between(IndieBlueprintGlobalClock.current_hour, dusk_hour, night_hour - 1)
	
	return false

## Curve is 0.87 when start night
func is_night() -> bool:
	if use_global_day_night_clock:
		var current_hour = IndieBlueprintGlobalClock.current_hour
		
		return IndieBlueprintMathHelper.value_is_between(current_hour, night_hour, IndieBlueprintGlobalClock.DayHourLength - 1) \
			or IndieBlueprintMathHelper.value_is_between(current_hour, 0, dawn_hour)
	
	return false


func adjust_day_panorama() -> void:
	if world_environment.environment.sky.sky_material is ShaderMaterial:
		world_environment.environment.sky.sky_material.set_shader_parameter("panorama", available_day_panoramas.pick_random())
	

func adjust_panorama_based_on_hour() -> void:
	if use_global_day_night_clock:
		if IndieBlueprintMathHelper.value_is_between(IndieBlueprintGlobalClock.current_hour, dusk_hour, night_hour, false):
			
			if world_environment.environment.sky.sky_material is ShaderMaterial:
				world_environment.environment.sky.sky_material.set_shader_parameter("panorama", available_dusk_panoramas.pick_random())
	
	
func update_day_zone() -> void:
	if IndieBlueprintGlobalClock.current_hour == dawn_hour:
		current_day_zone = DawnZone
		changed_day_zone.emit(NightZone, DawnZone)
		
	elif IndieBlueprintGlobalClock.current_hour == day_hour:
		current_day_zone = DayZone
		changed_day_zone.emit(DawnZone, DayZone)
		
	elif IndieBlueprintGlobalClock.current_hour == dusk_hour:
		current_day_zone = DuskZone
		changed_day_zone.emit(DayZone, DuskZone)
		
	elif IndieBlueprintGlobalClock.current_hour == night_hour:
		current_day_zone = NightZone
		changed_day_zone.emit(DuskZone, NightZone)
	

func _connect_to_global_day_night_clock() -> void:
	if use_global_day_night_clock and is_inside_tree():
		if not IndieBlueprintGlobalClock.day_passed.is_connected(on_day_passed):
			IndieBlueprintGlobalClock.day_passed.connect(on_day_passed)
		
		if not IndieBlueprintGlobalClock.hour_passed.is_connected(on_hour_passed):
			IndieBlueprintGlobalClock.hour_passed.connect(on_hour_passed)


func on_day_passed() -> void:
	if sun_change_rotation_on_new_day:
		sun.rotation_degrees += sun_change_rotation_amount
		
	if moon_change_rotation_on_new_day:
		moon.rotation_degrees += moon_change_rotation_amount
	
	adjust_day_panorama()


func on_hour_passed() -> void:
	adjust_panorama_based_on_hour()
	update_day_zone()
