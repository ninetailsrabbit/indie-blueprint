## Achieve a parallax effect when moving the mouse around the screen
## This node needs to be the root parent, child ui nodes inherit this effect.
@icon("res://ui/mouse/parallax/mouse_parallax.svg")
class_name MouseParallax extends Control


@export var max_offset := Vector2(12, 10)
@export var lerp_smoothing: float = 2.0


func _process(delta):
	var center: Vector2 = get_viewport_rect().size / 2.0
	var dist: Vector2 = get_global_mouse_position() - center
	var offset: Vector2 = dist / center
	
	var new_position: Vector2
	
	new_position.x = lerp(max_offset.x, -max_offset.x, offset.x)
	new_position.y = lerp(max_offset.y, -max_offset.y, offset.y)
	
	position.x = lerp(position.x, new_position.x, lerp_smoothing * delta)
	position.y = lerp(position.y, new_position.y, lerp_smoothing * delta)
