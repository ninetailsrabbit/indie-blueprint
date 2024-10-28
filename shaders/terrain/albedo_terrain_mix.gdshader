// https://godotshaders.com/shader/albedo-terrain-mix-shader/
shader_type spatial;

uniform sampler2D source_texture_mask : source_color;
uniform sampler2D source_texture_black : source_color;
uniform sampler2D source_texture_red : source_color;
uniform sampler2D source_texture_green : source_color;
uniform sampler2D source_texture_blue : source_color;

uniform float uv_size : hint_range(0.01, 100.0, 0.01) = 1.0;

void fragment() {

vec2 UV_Scaled = UV * uv_size;

// texture_rgbmask UV is not scaled.
vec3 texture_rgbmask= texture(source_texture_mask, UV).rgb; 
vec3 texture_black 	= texture(source_texture_black, UV_Scaled).rgb;
vec3 texture_red 	= texture(source_texture_red, UV_Scaled).rgb;
vec3 texture_green 	= texture(source_texture_green, UV_Scaled).rgb;
vec3 texture_blue 	= texture(source_texture_blue, UV_Scaled).rgb;

float summed_texture_channels = (
	texture_rgbmask.r + 
	texture_rgbmask.g + 
	texture_rgbmask.b);

vec3 mixed_terrain = clamp(
		(	texture_rgbmask.r * texture_red +
			texture_rgbmask.g * texture_green +
			texture_rgbmask.b * texture_blue) /
			summed_texture_channels,
			vec3(0.0), vec3(1.0) // Clamp min, max values.
			);

ALBEDO = mix(mixed_terrain,texture_black,1.0 - summed_texture_channels);

} // Fragment end