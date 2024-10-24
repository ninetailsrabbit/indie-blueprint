class_name SmartDecal extends Decal

## The minimum size this decal can have. Set both min_size and max_size to not apply a random range between them
@export var min_size: Vector3 = Vector3.ONE
## The maximum size this decal can have. Set both min_size and max_size to not apply a random range between them
@export var max_size: Vector3 = Vector3.ONE
## The randomization of range size it's equal so x,y,z have the same value. It uses the 'x' value from size vectors
@export var random_size_equals: bool = true
## A fade out animation after time in seconds. Set to zero to disable it and keep the decal on the world.
@export var fade_after: float = 3.0
## The time that takes to fade out the decal when fade_after it's enabled.
@export var fade_out_time: float = 1.5
## Randomize the spin on the Y axis to create a more natural feeling
@export var spin_randomization: bool = false


func _enter_tree() -> void:
	adjust_size()


func adjust_size() -> void:
	if not min_size.is_zero_approx() and not max_size.is_zero_approx():
		if random_size_equals:
			size  = Vector3.ONE * randf_range(min_size.x, max_size.x)
		else:
			size = Vector3(randf_range(min_size.x, max_size.x), randf_range(min_size.y, max_size.y), randf_range(min_size.z, max_size.z))
	elif min_size.is_zero_approx() and not max_size.is_zero_approx():
		size = max_size
	elif not min_size.is_zero_approx() and max_size.is_zero_approx():
		size = min_size
	

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
