shader_type spatial;
render_mode cull_disabled, world_vertex_coords, depth_draw_always, ambient_light_disabled, diffuse_burley, fog_disabled;

uniform float sync_time;

varying vec3 triplanar_pos;
varying vec3 power_normal;
varying vec3 world_normal;
varying vec3 object_normal;

uniform float wave_speed = 0.1;


uniform float opacity : hint_range(0.0, 1.0, 0.01) = 0.4;

uniform sampler2D albedo;

uniform float height_scale = 0.1;
uniform float amplitude1 = 0.5;
uniform float amplitude2 = 0.5;

uniform sampler2D vertex_noise_big : repeat_enable;
uniform sampler2D vertex_noise_big2 : repeat_enable;

uniform int v_noise_tile : hint_range(0, 300, 1) = 1;

uniform float v_normal_scale = 0.5;

varying flat vec3 norm;



uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;


varying vec3 npw;


varying vec3 v_color;

varying vec3 lighting;

vec2 round_to_pixel(vec2 i, int width)
{
	
	float denom = 1.0 / float(width);
	float _x = i.x + abs(mod(i.x, denom) - denom);
	float _y = i.y + abs(mod(i.y , denom) - denom);
	return vec2(_x, _y);
}

float round_to_pixel_f(float i, int width)
{
	
	float denom = 1.0 / float(width);
	float _x = i + abs(mod(i, denom) - denom);
	return _x;
}

float remap(float in_low, float in_high, float out_low, float out_high, float value)
{
	return out_low + (value - in_low) * (out_high - out_low) / (in_high - in_low);
}


// global uv
vec2 g_uv(vec2 uv, float speed, bool flipped, vec3 n) {
	
	vec2 _xy;
	_xy.x = uv.x;
	_xy.y = uv.y;
	
	float t_s = TIME * speed;
	
	if(!flipped)
	{
		_xy.x += t_s;
		_xy.y += t_s;
	} else {
		_xy.x -= t_s;
		_xy.y -= 0.0;
	}
	
	return _xy;
	
}	

vec2 g_v(vec2 v, vec3 n, bool flipped)
{

	float f_v_n_t = float(v_noise_tile);
	
	v.x = mod(v.x, f_v_n_t);
	v.y = mod(v.y, f_v_n_t);
	
	vec2 _mapped = vec2(remap(0, f_v_n_t, 0, 1, v.x), remap(0, f_v_n_t, 0, 1, v.y));
	
	_mapped += n.xz;
	if(flipped)
	{
		_mapped.y -= (sync_time) * wave_speed;
	} else {
		_mapped.x += (sync_time) * wave_speed;
	}
	
	_mapped.x = mod(_mapped.x, 1);
	
	return _mapped;
	
}

vec2 rotate(vec2 n, float angle) {
	float _ar = radians(angle);
	float _x = n.x * (cos(_ar) - sin(_ar));
	float _y = n.y * (sin(_ar) - cos(_ar));
	return vec2(_x, _y);
}

float wave(vec2 y, vec3 n) {
	//sad
	
	vec2 _y1 = g_v(y, n, false);
	vec2 _y2 = g_v(y + vec2(0.3, 0.476), n, true);
	
	float s = 0.0;
	//s = texture(vertex_noise, mod(_y1, float(v_noise_tile))).r * amplitude1;
	s += texture(vertex_noise_big, mod(_y1, float(v_noise_tile))).r * amplitude1;
	s += texture(vertex_noise_big2, mod(_y2, float(v_noise_tile))).r * amplitude2;
	
	s -= height_scale/2.;
	
	
	return s;
}

void vertex() {

	npw = NODE_POSITION_WORLD;


	vec2 adj_v_pos = VERTEX.xz;

	float _height = wave(adj_v_pos, NODE_POSITION_WORLD) * height_scale;
	VERTEX.y += _height;

	vec2 e = vec2(0.1, 0.0);
	float v_scale = height_scale * v_normal_scale;

	vec3 normal = normalize(vec3(wave(adj_v_pos - e, NODE_POSITION_WORLD) * v_scale - wave(adj_v_pos + e, NODE_POSITION_WORLD) * v_scale, 1.0 * e.x, wave(adj_v_pos - e.yx, NODE_POSITION_WORLD) * v_scale - wave(adj_v_pos + e.yx, NODE_POSITION_WORLD) * v_scale));

	NORMAL = normal;
	
	
	triplanar_pos = VERTEX.xyz * vec3(1.0, 0, 1.0);
	
	v_color = COLOR.rgb;
	
}



void fragment() {
	
	ALBEDO = texture(albedo, UV).rgb;

}

void light()
{


}

