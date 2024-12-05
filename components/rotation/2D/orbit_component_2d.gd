@icon("res://components/rotation/2D/orbit_component_2d.svg")
class_name OrbitComponent2D extends Node

signal started
signal stopped

@export var target: Node2D
@export var radius: float = 40.0
@export_range(0, 360, 0.01, "degrees") var angle: float = 45.0:
	set(value):
		angle = value
		current_angle = deg_to_rad(angle)
@export var angular_velocity = PI / 2

## Current angle in radians
var current_angle: float = angle:
	set(value):
		current_angle = clampf(value, 0.0, TAU)

var active: bool = false:
	set(value):
		if value != active:
			if value:
				started.emit()
				set_process(true)
			else:
				stopped.emit()
				
			active = value
			set_process(active)
			
func _ready():
	if target == null:
		target = get_parent() as Node2D
	
	assert(target is Node2D, "OrbitComponent2D: This component needs a Node2D target to apply the orbit")
	
	current_angle = angle


func _process(delta):
	if active:
		current_angle += delta * angular_velocity
		current_angle = fmod(current_angle, TAU)
		
		var offset: Vector2 = Vector2(cos(current_angle), sin(current_angle)) * radius
		target.position = target.position + offset
		

func start():
	active = true
	
	
func stop():
	active = false
