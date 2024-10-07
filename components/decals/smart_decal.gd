class_name SmartDecal extends Decal

## A fade out animation after time in seconds
@export var fade_after: float = 3.0
@export var fade_out_time: float = 1.5
@export var spin_randomization: bool = false

func _ready() -> void:
	show()
	

func adjust_to_normal(normal: Vector3) -> void:
	if not normal.is_equal_approx(Vector3.UP) and not normal.is_equal_approx(Vector3.DOWN):
		look_at(global_position + normal, Vector3.UP)
		rotate_object_local(Vector3.RIGHT, PI / 2)
		
	if spin_randomization:
		rotate_object_local(Vector3.UP, randf_range(0, TAU))
	
	if fade_after > 0:
		fade_out()
		

func fade_out(time: float = fade_out_time) -> void:
	var tween = create_tween()
	tween.tween_interval(fade_after)
	tween.tween_property(self, "modulate:a", 0, time)
	
	await tween.finished
	
	queue_free()
