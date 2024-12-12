## A static rainbow effect to change the colors of each letter managing the hue
@tool
class_name RichTextHueShift extends RichTextEffect

var bbcode: String = "hue"

@export var hue_shift_speed: float = 0.1
@export var hue_shift_amount: float = 0.1
@export var hue_gliph_offset: float = 0.1
@export var hue_gliph_random: float = 0.1
@export var hue_sat_offset: float = -0.25


func _process_custom_fx(char_fx: CharFXTransform):
	var col: Color = char_fx.color
	var hsv: Vector3 = Vector3(char_fx.color.h, char_fx.color.s, char_fx.color.v)
	
	hsv.y += hue_sat_offset
	hsv.x += (hue_shift_speed * char_fx.elapsed_time) * hue_shift_amount
	hsv.x += hue_gliph_offset * char_fx.relative_index
	
	var rand: float = float(rand_from_seed(char_fx.relative_index + char_fx.glyph_index)[0])/float( (1 << 32) - 1 )
	hsv.x += hue_gliph_random * rand
	char_fx.color = Color.from_hsv(fmod(hsv.x,1.0), hsv.y, hsv.z, col.a)
		
	return true
