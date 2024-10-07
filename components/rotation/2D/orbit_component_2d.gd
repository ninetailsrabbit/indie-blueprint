@icon("res://components/rotation/2D/orbit_component_2d.svg")
class_name OrbitComponent2D extends Node2D

signal started
signal stopped

@export var rotation_reference: Node2D
@export var radius: float = 40.0
@export var angle_in_radians = PI / 4
@export var angular_velocity = PI / 2


var active: bool = false:
	set(value):
		if value != active:
			if value:
				started.emit()
				set_process(true)
			else:
				stopped.emit()
				set_process(false)
				
		active = value

func _ready():
	if rotation_reference == null:
		rotation_reference = get_parent() as Node2D
	
	assert(rotation_reference is Node2D, "OrbitComponent2D: This component needs a Node2D rotation reference to apply the orbit")
	
	
	
func _process(delta):
	active = true
	angle_in_radians += delta * angular_velocity
	angle_in_radians %= TAU
	
	var offset: Vector2 = Vector2(cos(angle_in_radians), sin(angle_in_radians)) * radius
	position = rotation_reference.position + offset
	

func start():
	active = true
	
	
func stop():
	active = false
