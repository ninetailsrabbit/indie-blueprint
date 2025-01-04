shader_type spatial;
render_mode cull_disabled, world_vertex_coords, depth_draw_always, ambient_light_disabled, diffuse_burley, specular_disabled;

varying vec3 triplanar_pos;
varying vec3 power_normal;
varying vec3 world_normal;
varying vec3 object_normal;

uniform float wave_speed = 0.1;
uniform float caustic_speed = 0.01;

uniform float aa;

uniform float transmittence = 1.0;

uniform float depth_fade : hint_range(0.0, 0.5, 0.01) = 0.3;
uniform float depth_fade_distance : hint_range(0.0, 100.0, 0.1) = 5.0;

uniform vec3 surface_albedo_shallow : source_color;
uniform vec3 surface_albedo_deep : source_color;
uniform vec4 surface_bottom : source_color;

uniform float opacity : hint_range(0.0, 1.0, 0.01) = 0.4;

uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.4;

uniform float height_scale = 0.1;
uniform float amplitude1 = 0.5;
uniform float amplitude2 = 0.5;

uniform sampler2D vertex_noise : repeat_enable;
uniform sampler2D vertex_noise_big : repeat_enable;
uniform sampler2D vertex_noise_big2 : repeat_enable;

uniform int v_noise_tile : hint_range(0, 300, 1) = 1;
uniform float v_normal_scale = 0.5;

varying flat vec3 norm;

uniform sampler2D normal_noise : hint_normal, filter_linear_mipmap;
uniform float normal_noise_size = 5.0;

uniform int normal_map_w = 256;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;

uniform float wobble_power = 0.01;
uniform sampler2D under_wobble_noise;

varying vec3 npw;

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
		_mapped.y -= TIME * wave_speed;
	} else {
		_mapped.x += TIME * wave_speed;
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
	
	COLOR.xyz = vec3(.2, .2, .4);
	
	triplanar_pos = VERTEX.xyz * vec3(1.0, 0, 1.0);
	
	
}



void fragment() {
	
	// render the top
	ROUGHNESS = roughness;
	vec3 _albedo = surface_albedo_deep;
	vec3 deep = surface_albedo_deep;
	
	vec2 wobble_uv = (texture(under_wobble_noise, g_uv(UV, caustic_speed, false, NODE_POSITION_WORLD) * 10.0).xy * wobble_power);
	wobble_uv -= wobble_power * 0.86;
	
	// im not sure why but without the * 0.25, the colors are way too bright
	vec3 under = texture(screen_texture, SCREEN_UV + wobble_uv).rgb * opacity;
	
	
	// code from: https://github.com/godotengine/godot/issues/77798#issuecomment-1575222421
	float depth2 = texture(depth_texture, SCREEN_UV + wobble_uv).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth2);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_texture_y = world.y / world.w;
	depth_texture_y += CAMERA_POSITION_WORLD.y;
	// fixes waves peaking above camera position being considered low depth.
	if (depth_texture_y >= depth_fade_distance)
	{
		depth_texture_y = -100.;
	}
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	float vertical_depth = vertex_y - depth_texture_y;

	// Changes the color of geometry behind it as the water gets deeper
	float depth_fade_blend = exp(-vertical_depth / depth_fade_distance);
	
	depth_fade_blend = clamp(depth_fade_blend, 0.0, 1.0);
	

	
	// Makes the water more transparent as it gets more shallow
	float alpha_blend = -vertical_depth * transmittence;
	alpha_blend = clamp(1.0 - exp(alpha_blend), 0.6, 1.0);
	

	deep = mix(surface_albedo_deep, surface_albedo_shallow, depth_fade_blend);
	
	
	//surface = mix(surface_albedo_deep, surface_albedo_shallow, depth_blend);
	
	vec2 rounded_uv = round_to_pixel((triplanar_pos.xz * (1.0 / normal_noise_size)) * 0.1, normal_map_w);

	
	NORMAL_MAP = texture(normal_noise, rounded_uv).rgb;
	
	if(FRONT_FACING)
	{
		_albedo = mix(under, deep, alpha_blend);
	} else {
		NORMAL = -NORMAL;
		NORMAL_MAP = mix(vec3(1.,1.,1.), vec3(0.,0.,0.), NORMAL_MAP);
		vec3 over = texture(screen_texture, SCREEN_UV + wobble_uv).rgb;
		_albedo = mix(over, surface_bottom.rgb, surface_bottom.a);
		
	}
	ALBEDO = _albedo;
	
}


uniform float specular_strength : hint_range(0.0f, 1.0f) = 1.0f;
uniform float specular_shininess : hint_range(0.0f, 32.0f) = 16.0f;


uniform float shadow : hint_range(0.0, 1.0) = 0.5;
uniform float shadow_width : hint_range(0.001, 0.5) = 0.0;
uniform vec4 shadow_color: source_color = vec4(0.705);

uniform float _specular_smoothness : hint_range(0.0,0.5) = 0.01;
uniform float _specular_strength : hint_range(0.0,9.25) = 0.075;
uniform float _glossiness : hint_range(0.0,0.5) = 0.1;

//uniform float _rim_size : hint_range(0,1) = 0.5;
//uniform float _rim_smoothness : hint_range(0.0,0.5) = 0.01;

// light shader code from: https://godotshaders.com/shader/toon/ and https://godotshaders.com/shader/flexible-toon-shader-godot-4/
void light()
{
	vec3 H = normalize(LIGHT);
		float NdotH = dot(NORMAL, H);
		float specular_amount = max(pow(NdotH, specular_shininess*specular_shininess), 0.0f)
								* ATTENUATION;
	SPECULAR_LIGHT = specular_strength * specular_amount * LIGHT_COLOR;
		
	float NdotL = dot(NORMAL, LIGHT) * ATTENUATION;
	NdotL = smoothstep(shadow - shadow_width, shadow + shadow_width, NdotL);
	
	// specular
	//vec3 H = normalize(VIEW + LIGHT);
	float specular_intensity = pow(NdotH, 1.0 / _glossiness);
	vec3 specular = vec3(smoothstep(0.5 - _specular_smoothness, 0.5 + _specular_smoothness, specular_intensity));
	
	// rim related stuff, not used
	//float rimDot = 1.0 - dot(VIEW, NORMAL);
	//float rim_intensity = rimDot * NdotL;
	//vec3 rim = vec3(smoothstep(1.0 -_rim_size - _rim_smoothness, 1.0 -_rim_size + _rim_smoothness, rim_intensity));
	vec3 rim = vec3(1.0);
	float rimDot = 1.0 - NORMAL.z;
	
	DIFFUSE_LIGHT = mix(ALBEDO * shadow_color.rgb, (ALBEDO + (rim + specular) * _specular_strength) * LIGHT_COLOR.rgb * 0.33, NdotL + 0.33/* * (smoothstep(1.0 -_rim_size - _rim_smoothness, 1.0 -_rim_size + _rim_smoothness, rimDot))*/);
}

