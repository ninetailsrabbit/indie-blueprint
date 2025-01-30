shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform vec3 color : source_color;
uniform float blur : hint_range(0, 5) = 1.0; // Strength of the blur effect
uniform float blend : hint_range(0, 1) = 0.5; // Radius of the blur effect
uniform float noise : hint_range(0, 1) = 0.5; // Radius of the blur effect

void fragment() {
	vec2 uv = SCREEN_UV;
	uv.x += sin(SCREEN_UV.y * 10.0 + TIME * noise) * 0.01;
	uv.y += sin(SCREEN_UV.x * 10.0 + TIME * noise) * 0.01;

    vec4 pixelColor = texture(screen_texture, UV);
    vec4 blurColor = textureLod(screen_texture, uv, blur);
    blurColor.rgb = mix(blurColor.rgb, color, blend);
    COLOR = blurColor;
}