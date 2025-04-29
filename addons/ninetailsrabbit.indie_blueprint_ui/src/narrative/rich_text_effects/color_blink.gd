@tool
class_name RichTextColorBlink extends RichTextEffect


var bbcode: String = "colorblink"

@export var fx_color: Color = Color.YELLOW

func _process_custom_fx(char_fx):
	var t: float = smoothstep(0.3, 0.6, sin(char_fx.elapsed_time * 4.0) * 0.5 + 0.5)
	char_fx.color = lerp(char_fx.color, fx_color, t)

	return true
