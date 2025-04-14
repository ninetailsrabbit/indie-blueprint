class_name BulletTrace extends Node3D


@export var speed: float = 50.0
@export var alive_time: float = 1.0
@export var alive_timer: Timer 


var shoot_direction: Vector3 = Vector3.ZERO


func _ready() -> void:
	top_level = true
	
	if shoot_direction.is_zero_approx():
		shoot_direction = IndieBlueprintCamera3DHelper.forward_direction(get_viewport().get_camera_3d())
	
	alive_timer.timeout.connect(on_alive_timer_timeout)
	alive_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	alive_timer.one_shot = true
	alive_timer.autostart = false
	alive_timer.start(alive_time)
	
	
func _physics_process(delta: float) -> void:
	global_position += shoot_direction * speed * delta


func on_alive_timer_timeout() -> void:
	queue_free()
