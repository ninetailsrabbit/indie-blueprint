@tool
class_name IndieBlueprintOrbitComponent2D extends Node

signal started
signal stopped

@export var orbit_around: Node2D
@export var target: Node2D
@export var active: bool = false:
	set(value):
		if value != active:
			active = value
			
			if active:
				started.emit()
			else:
				stopped.emit()
			
			set_process(active)

@export var radius: float = 40.0
@export_range(0, 360, 0.01, "degrees") var initial_angle: float = 45.0:
	set(value):
		initial_angle = value
		current_angle = deg_to_rad(initial_angle)
@export var angular_velocity: float = PI / 2

## Current angle in radians
var current_angle: float = initial_angle:
	set(value):
		current_angle = clampf(value, 0.0, TAU)


func _ready():
	assert(target is Node2D and orbit_around is Node2D and target != orbit_around, "IndieBlueprintOrbitComponent2D: This component needs a Node2D target and orbit around to apply the orbit and cannot be the same node")
	
	current_angle = deg_to_rad(initial_angle)
	set_process(active)


func _process(delta: float):
	if target:
		current_angle += delta * angular_velocity
		current_angle = fmod(current_angle, TAU)
		
		var offset: Vector2 = Vector2(cos(current_angle), sin(current_angle)) * radius
		target.position = orbit_around.position + offset
		

func start():
	active = true
	
	
func stop():
	active = false
