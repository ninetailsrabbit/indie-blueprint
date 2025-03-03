// Source: https://github.com/GDQuest/godot-shaders/blob/master/godot/Shaders/dissolve2D.shader
// Modified to support the selected Screen Color
shader_type canvas_item;

uniform sampler2D dissolve_texture;
uniform float dissolve_amount : hint_range(0, 1);

void fragment() {
	vec4 out_color = COLOR;
	float sample = texture(dissolve_texture, UV).r;
	COLOR = vec4(out_color.rgb, smoothstep(dissolve_amount - 0.01, dissolve_amount + 0.01, sample) * out_color.a);
}