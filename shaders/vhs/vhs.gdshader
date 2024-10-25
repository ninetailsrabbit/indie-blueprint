// adapted from:
// https://www.shadertoy.com/view/Ms3XWH

shader_type canvas_item;
uniform float shake: hint_range(0, 10) = 0.015;
uniform float noiseQuality: hint_range(0.1, 250,0.1) = 250;
uniform float noiseIntensity: hint_range(0, 0.05,0.001) = 0.001;
uniform float offsetIntensity: hint_range(0, 0.05,0.0001) = 0.05;
uniform float colorOffsetIntensity: hint_range(0.1, 1.5,0.001) = 0.5;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset)
{
    float edge0 = (pos - shake);
    float edge1 = (pos + shake);

    float x = smoothstep(edge0, pos, uvY) * offset;
    x -= smoothstep(pos, edge1, uvY) * offset;
    return x;
}


void fragment() {
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy / iResolution.xy;
    // why these values for i?
    for (float i = 0.0; i < 0.71; i += 0.1313)
    {
        float d = mod(TIME * i, 1.7);
        float o = sin(1.0 - tan(TIME * 0.24 * i));
    	o *= offsetIntensity;
        uv.x += verticalBar(d, uv.y, o);
    }
	float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(vec2(TIME* 0.00001, uvY));
    uv.x += noise * noiseIntensity;

	vec2 offsetR = vec2(0.006 * sin(TIME), 0.0) * colorOffsetIntensity;
    vec2 offsetG = vec2(0.0073 * (cos(TIME * 0.97)), 0.0) * colorOffsetIntensity;

	float r = texture(screen_texture, uv + offsetR).r;
    float g = texture(screen_texture, uv + offsetG).g;
    float b = texture(screen_texture, uv).b;

	//vec4 tex = vec4(r, g, b, 1.0);
	vec4 tex=vec4(r, g, b,1.0);
    COLOR = tex;
}