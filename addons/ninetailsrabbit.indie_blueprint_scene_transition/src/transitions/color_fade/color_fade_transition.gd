class_name ColorFadeTransition extends IndieBlueprintSceneTransition


@export var default_color: Color = Color("050505")
@export var default_duration: float = 1.0
@export var in_start_modulate: int = 0
@export var out_start_modulate: int = 255
@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	prepare_color_rect(color_rect)
	color_rect.modulate.a8 = 0


func transition_in(args: Dictionary = {}) -> void:
	in_transition_started.emit()
	
	prepare_color_rect(color_rect)
	color_rect.color = args.get_or_add("color", default_color)
	color_rect.modulate.a8 = in_start_modulate
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a8", 255, args.get_or_add("duration", default_duration))\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	tween.finished.connect(func(): in_transition_finished.emit(), CONNECT_ONE_SHOT)


func transition_out(args: Dictionary = {}) -> void:
	out_transition_started.emit()
	
	prepare_color_rect(color_rect)
	color_rect.color = args.get_or_add("color", default_color)
	color_rect.modulate.a8 = out_start_modulate
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a8", 0, args.get_or_add("duration", default_duration))\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	tween.finished.connect(func(): out_transition_finished.emit(), CONNECT_ONE_SHOT)
