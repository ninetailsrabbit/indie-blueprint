shader_type spatial;
render_mode cull_disabled, world_vertex_coords, depth_draw_always, ambient_light_disabled, diffuse_burley, depth_prepass_alpha;

uniform float speed = 0.01;

uniform sampler2D color_gradient;

uniform sampler2D noise;

void fragment() {
	
	vec2 _uv = UV + TIME * speed;
	vec2 _uv2 = UV - TIME * speed;

	float _sample = texture(noise, _uv).r;
	_sample = mix(_sample, texture(noise, _uv2).r, 0.5);

	ALBEDO = texture(color_gradient, vec2(_sample)).rgb;
	ALPHA = 1.0;
}

