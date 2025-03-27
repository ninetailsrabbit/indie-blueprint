@icon("res://components/interaction/3D/lights/random_light_energy.svg")
class_name IndieBlueprintRandomLightEnergy3D extends Node

@export var light: Light3D
@export var min_variation: float = 0.8
@export var max_variation: float = 1.2
@export var speed: float = 25.0
@export var autostart: bool = true

@onready var float_time_1: float = randf() * TAU
@onready var float_time_2: float = randf() * TAU


var original_light_energy: float
var active: bool = false:
	set(value):
		if value != active:
			active = value
			
			if active:
				enable()
			else:
				disable()
			
			set_process(active)


func _ready():
	assert(light is Light3D, "RandomLightEnergy3D: This node does not have assigned a Light3D")
	original_light_energy = light.light_energy
	
	active = autostart
	
	if active:
		enable()
	else:
		disable()


func _process(delta):
	float_time_1 = wrapf(float_time_1 + delta * speed, 0, TAU)
	float_time_2 = wrapf(float_time_2 + delta * speed * 1.423, 0, TAU)
	
	var random = (sin(float_time_1) + cos(float_time_2)) / 2
	
	light.light_energy = original_light_energy * remap(random, 0, 1, min_variation, max_variation)


func enable():
	active = true


func disable():
	active = false
