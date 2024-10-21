shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float screen_width = 1280;
uniform float screen_height = 720;

// Curvature
uniform float BarrelPower =1.1;
// Color bleeding
uniform float color_bleeding = 1.2;
uniform float bleeding_range_x = 3;
uniform float bleeding_range_y = 3;
// Scanline
uniform float lines_distance = 4.0;
uniform float scan_size = 2.0;
uniform float scanline_alpha = 0.9;
uniform float lines_velocity = 30.0;

vec2 distort(vec2 p)
{
	float angle = p.y / p.x;
	float theta = atan(p.y,p.x);
	float radius = pow(length(p), BarrelPower);

	p.x = radius * cos(theta);
	p.y = radius * sin(theta);

	return 0.5 * (p + vec2(1.0,1.0));
}

void get_color_bleeding(inout vec4 current_color,inout vec4 color_left){
	current_color = current_color*vec4(color_bleeding,0.5,1.0-color_bleeding,1);
	color_left = color_left*vec4(1.0-color_bleeding,0.5,color_bleeding,1);
}

void get_color_scanline(vec2 uv,inout vec4 c,float time){
	float line_row = floor((uv.y * screen_height/scan_size) + mod(time*lines_velocity, lines_distance));
	float n = 1.0 - ceil((mod(line_row,lines_distance)/lines_distance));
	c = c - n*c*(1.0 - scanline_alpha);
	c.a = 1.0;
}

void fragment()
{
	vec2 xy = SCREEN_UV * 2.0;
	xy.x -= 1.0;
	xy.y -= 1.0;

	float d = length(xy);
	if(d < 1.5){
		xy = distort(xy);
	}
	else{
		xy = SCREEN_UV;
	}

	float pixel_size_x = 1.0/screen_width*bleeding_range_x;
	float pixel_size_y = 1.0/screen_height*bleeding_range_y;
	vec4 color_left = texture(SCREEN_TEXTURE,xy - vec2(pixel_size_x, pixel_size_y));
	vec4 current_color = texture(SCREEN_TEXTURE,xy);
	get_color_bleeding(current_color,color_left);
	vec4 c = current_color+color_left;
	get_color_scanline(xy,c,TIME);
	COLOR = c;

}