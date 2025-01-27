@icon("res://components/vfx/2D/ghost_trail/ghost.svg")
class_name GhostTrailEffect extends Node2D

## An Sprite2D or AnimatedSprite2D are valid to apply the ghost effect
@export var target: Node2D
## To apply the ghost effect on each frames interval, higher values mean more separation between ghosts
@export_range(0, 60, 1) var frames_interval: int = 15
@export var only_modify_alpha: bool = true
@export_range(0, 255, 1) var ghost_effect_alpha: int = 200
@export_range(0, 255, 1) var ghost_effect_vanish_time: float = 0.7
@export var ghost_effect_color: Color = Color.WHITE


var enabled: bool = false:
	set(value):
		enabled = value
		set_process(enabled)
		
		
func _ready() -> void:
	assert(target != null and (target is Sprite2D or target is AnimatedSprite2D), "GhostEffect: The target node needs to be a Sprite2D or AnimatedSprite2D")
	
	set_process(enabled)
	

func _physics_process(_delta: float) -> void:
	if Engine.get_physics_frames() % frames_interval == 0:
		apply()
	

func apply():
	if enabled and target:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = target.sprite_frames.get_frame_texture(target.animation, target.frame) if target is AnimatedSprite2D else target.texture

		get_tree().root.add_child(sprite)
		
		sprite.global_position = target.global_position
		sprite.scale = target.scale
		sprite.flip_h = target.flip_h
		sprite.flip_v = target.flip_v
		
		if only_modify_alpha:
			sprite.modulate.a8 = ghost_effect_alpha 
		else:
			sprite.modulate = Color(ghost_effect_color, ghost_effect_alpha / 255.0)
		
		var tween: Tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, ghost_effect_vanish_time)\
			.set_trans(tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		tween.tween_callback(sprite.queue_free)


func start() -> void:
	enabled = true
	
	
func stop() -> void:
	enabled = false
