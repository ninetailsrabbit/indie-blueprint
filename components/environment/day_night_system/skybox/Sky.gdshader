shader_type sky;
render_mode use_half_res_pass;

group_uniforms sky;

uniform vec3 sky_color :  source_color = vec3(1.0);
uniform vec3 horizon_color : source_color = vec3(1.0);
uniform vec3 ground_color : source_color = vec3(0.0);
uniform sampler2D panorama : filter_linear, source_color, hint_default_white;

group_uniforms sun;

uniform bool sun = false;
uniform vec3 sun_color: source_color = vec3(1.0);
uniform float sun_size: hint_range(0.0, 1.0, 0.01) = 0.05;
uniform float sun_blur: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float sun_disc: hint_range(0.0, 1.0, 0.1) = 0.5;

vec3 hard_light(vec3 base, vec3 blend)
{
	vec3 limit = step(0.5, blend);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

void sky()
{
	vec3 gradients = mix(ground_color.rgb, sky_color.rgb, clamp(EYEDIR.y / 0.1, 0.0, 1.0));
	vec3 horizon = clamp((1.0 - abs(EYEDIR.y / 0.5)) * clamp(LIGHT0_DIRECTION.y, 0.0, 1.0), 0.0, 1.0) * horizon_color.rgb;

	if (sun) {
		float sun_distance = distance(EYEDIR, LIGHT0_DIRECTION);
		float sun_power = 1.0 - clamp(sun_distance / sun_size, 0.0, 1.0);
		float sun_output = clamp(sun_power / sun_blur, sun_power, 1.0);

		float disc_power = 1.0 - clamp(sun_distance / sun_disc, 0.0, 1.0);
		vec3 disc_output = sun_color * disc_power;
		vec3 sun_effect = sun_color * sun_output + disc_output;
		vec3 sun_blend = hard_light(texture(panorama, SKY_COORDS).rgb, sun_effect);

		COLOR = texture(panorama, SKY_COORDS).rgb * gradients + horizon + sun_blend;
	}
	else {
		COLOR = texture(panorama, SKY_COORDS).rgb * gradients + horizon;
	}
}