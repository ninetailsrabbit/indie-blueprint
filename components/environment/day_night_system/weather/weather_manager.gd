class_name WeatherManager extends Node

@export var day_night_cycle: DayNightCycle


func _ready() -> void:
	day_night_cycle.changed_day_zone.connect(on_changed_day_zone)
	

func on_changed_day_zone(previous: StringName, current: StringName) -> void:
	pass
