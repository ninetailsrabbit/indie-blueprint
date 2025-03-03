shader_type canvas_item;

uniform float threshold : hint_range(-0.25,1);
uniform bool flip;

vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv, float columns, float rows) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1.0;

	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);

			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}

	return minimum_dist;
}

void fragment() {
	float worley = worley(UV + vec2(-TIME * 0.1, 0), 16.0, 9.0);
	float xGradient = UV.x;

		float t = threshold;
	if(flip) {
		xGradient = 1.0 - xGradient;
		t = 1.0 - t;
	}

	float alpha = (worley * 0.5 + xGradient * 1.5) / 2.0;

	alpha = step(alpha, threshold);

	COLOR.a = alpha;
}