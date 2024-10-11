shader_type canvas_item;

uniform float UPDATE_INTERVAL = .163;
uniform float STATIC_GRANULARITY = .005;
uniform float EDGE_BLUR = .5;
uniform float BORDER_SIZE = .3;

float generate_random_static(in float size, in float interval, in vec2 uv) {
	float time_step = TIME - mod(TIME,interval);
	vec2 uv_step = uv - mod(uv, size);
	return fract(sin(dot(uv_step,vec2(12.0278*sin(time_step),15.0905)))*43758.5453);
}

vec2 get_polar_coords(vec2 center, vec2 uv) {
	vec2 pos = uv-center;
	float r = length(pos);
	float theta = atan(pos.y,pos.x);
	return vec2(r,theta);
}

vec4 layer(in vec4 front_color, in vec4 back_color) {
	return vec4(mix(back_color.rgb,front_color.rgb,front_color.a),front_color.a+back_color.a);
}

void fragment() {
	vec3 static_plot = vec3(generate_random_static(STATIC_GRANULARITY,UPDATE_INTERVAL,UV));

	vec2 c1 = vec2(0.5);
	vec2 pv1 = get_polar_coords(c1,UV);
	float func = BORDER_SIZE-.015*cos(4.0*pv1.y);
	float border_plot = smoothstep(func,func+EDGE_BLUR, pv1.x);
	vec4 border_color = vec4(vec3(0.0),1.0)*border_plot;
	COLOR = vec4(static_plot,.1);
	COLOR = layer(COLOR,border_color);
}