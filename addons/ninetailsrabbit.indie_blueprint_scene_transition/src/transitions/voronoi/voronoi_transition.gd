class_name VoronoiTransition extends IndieBlueprintSceneTransition

@export var duration: float = 1.0
@export var color: Color = Color("050505")
@export var flip: bool = false

@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	prepare_color_rect(color_rect)


func transition_in(args: Dictionary = {}) -> void:
	in_transition_started.emit()
	
	color_rect.color = args.get_or_add("color", color)
	color_rect.material.set_shader_parameter("flip", args.get_or_add("flip", flip))
	
	var tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/threshold", 1.0, args.get_or_add("duration", duration))\
		.from(0.0)
		
	tween.finished.connect(func(): in_transition_finished.emit(), CONNECT_ONE_SHOT)

	
func transition_out(args: Dictionary = {}) -> void:
	out_transition_started.emit()
	
	color_rect.color = args.get_or_add("color", color)
	color_rect.material.set_shader_parameter("flip", args.get_or_add("flip", flip))
	
	var tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/threshold", 0.0, args.get_or_add("duration", duration))\
		.from(1.0)
		
	tween.finished.connect(func(): out_transition_finished.emit(), CONNECT_ONE_SHOT)
