shader_type canvas_item;

uniform float flash_opacity = 0;
uniform vec4 flash_color : source_color = vec4(1.0,1.0,1.0,1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
    vec3 blended_color = mix(tex_color.rgb, flash_color.rgb, flash_opacity); // Use only the RGB components for blending

	COLOR.rgb = blended_color;
	COLOR.a = tex_color.a;
}