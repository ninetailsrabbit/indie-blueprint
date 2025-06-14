class_name SpinSpriteComponent2D extends Node2D

@export var sprite: Sprite2D

var look_direction: Vector2 = Vector2.RIGHT:
	set(new_direction):
		if not look_direction.is_equal_approx(new_direction):
			look_direction = new_direction
			spin_to_direction(look_direction)
				
var skew_tween: Tween
var enabled: bool = false


func _ready() -> void:
	if sprite == null:
		sprite = get_parent()
		
	assert(sprite == null, "SpinSpriteComponent2D: This component needs a Sprite2D assigned")


func spin_to_direction(direction: Vector2) -> void:
	if enabled \
		and sprite \
		and direction in IndieBlueprintVectorHelper.horizontal_directions_v2 \
		and (skew_tween == null or (skew_tween and not skew_tween.is_running())):
			
		skew_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		skew_tween.tween_property(sprite, "scale:x", direction.x * absf(sprite.scale.x), 0.15)


func enable() -> void:
	enabled = true


func disable() -> void:
	enabled = false
