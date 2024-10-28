@icon("res://components/camera/3D/shake/trauma_detector.svg")
class_name TraumaDetector3D extends Area3D

@export var camera: CameraShake3D

func _ready():
	monitoring = false
	monitorable = true
	collision_layer = GameGlobals.shakeables_collision_layer
	collision_mask = 0 


func add_trauma(time: float, amount: float):
	if camera:
		camera.trauma(time, amount)


func enable():
	set_deferred("monitorable", true)
	

func disable():
	set_deferred("monitorable", false)
