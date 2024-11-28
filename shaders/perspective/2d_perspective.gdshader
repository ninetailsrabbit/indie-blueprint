// Hey this is Hei! This shader "fakes" a 3D-camera perspective on CanvasItems.
// License: MIT

shader_type canvas_item;

// Camera FOV
uniform float fov : hint_range(1, 179) = 90;
uniform bool cull_back = true;
// The shader works out-of-the-box with nodes Sprite and TextureRect, as long as the rect_size equals the size of the texture.
//  If this isn’t the case, set this parameter to false and set the correct size
uniform bool same_texture_size = true;
uniform vec2 rect_size = vec2(0, 0);
uniform float y_rot : hint_range(-180, 180) = 0.0;
uniform float x_rot : hint_range(-180, 180) = 0.0;
// At 0, the image retains its size when unrotated.
// At 1, the image is resized so that it can do a full
// rotation without clipping inside its rect.
uniform float inset : hint_range(0, 1) = 0.0;
// Consider changing this to a uniform and changing it from code

varying flat vec2 o;
varying vec3 p;


// Creates rotation matrix
void vertex(){
	float sin_b = sin(y_rot / 180.0 * PI);
	float cos_b = cos(y_rot / 180.0 * PI);
	float sin_c = sin(x_rot / 180.0 * PI);
	float cos_c = cos(x_rot / 180.0 * PI);

	mat3 inv_rot_mat;
	inv_rot_mat[0][0] = cos_b;
	inv_rot_mat[0][1] = 0.0;
	inv_rot_mat[0][2] = -sin_b;

	inv_rot_mat[1][0] = sin_b * sin_c;
	inv_rot_mat[1][1] = cos_c;
	inv_rot_mat[1][2] = cos_b * sin_c;

	inv_rot_mat[2][0] = sin_b * cos_c;
	inv_rot_mat[2][1] = -sin_c;
	inv_rot_mat[2][2] = cos_b * cos_c;


	float tang = tan(fov / 360.0 * PI);
	p = inv_rot_mat * vec3((UV - 0.5), 0.5 / tang);
	float v = (0.5 / tang) + 0.5;
	p.xy *= v * inv_rot_mat[2].z;
	o = v * inv_rot_mat[2].xy;

	if (same_texture_size) {
		VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * tang * (1.0 - inset);
	}
	else {
		VERTEX += (UV - 0.5) * rect_size * tang * (1.0 - inset);
	}
}

void fragment(){
	if (cull_back && p.z <= 0.0) discard;
	vec2 uv = (p.xy / p.z).xy - o;
    COLOR = texture(TEXTURE, uv + 0.5);
	COLOR.a *= step(max(abs(uv.x), abs(uv.y)), 0.5);
}