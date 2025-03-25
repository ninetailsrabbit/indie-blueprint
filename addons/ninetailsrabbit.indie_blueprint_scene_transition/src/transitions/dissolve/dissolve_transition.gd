class_name DissolveTransition extends IndieBlueprintSceneTransition

@export var duration: float = 1.0
@export var color: Color = Color("050505")
@export var texture: CompressedTexture2D = IndieBlueprintPremadeTransitions.NormalNoise

@onready var color_rect: ColorRect = $ColorRect


func transition_in(args: Dictionary = {}) -> void:
	in_transition_started.emit()
	
	color_rect.color = args.get_or_add("color", color)
	color_rect.material.set_shader_parameter("dissolve_texture", args.get_or_add("texture", texture))
	
	var tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/dissolve_amount", 0.0, args.get_or_add("duration", duration))\
		.from(1.0)
	
	tween.finished.connect(func(): in_transition_finished.emit(), CONNECT_ONE_SHOT)


func transition_out(args: Dictionary = {}) -> void:
	in_transition_started.emit()
	
	color_rect.color = args.get_or_add("color", color)
	color_rect.material.set_shader_parameter("dissolve_texture", args.get_or_add("texture", texture))

	var tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/dissolve_amount", 1.0, args.get_or_add("duration", duration))\
		.from(0.0)
		
	tween.finished.connect(func(): out_transition_finished.emit(), CONNECT_ONE_SHOT)
