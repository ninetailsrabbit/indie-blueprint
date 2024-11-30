@icon("res://components/camera/2D/shake/trauma_detector.svg")
class_name TraumaDetector2D extends Area2D

@export var camera: ShakeCamera2D

func _ready():
	monitoring = false
	monitorable = true
	collision_layer = GameGlobals.shakeables_collision_layer
	collision_mask = 0 


func add_trauma(amount: float):
	if camera:
		camera.add_trauma(amount)


func enable():
	set_deferred("monitorable", true)
	

func disable():
	set_deferred("monitorable", false)
