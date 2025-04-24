shader_type spatial;

uniform float radius : hint_range(0, 10) = 0.2;
uniform float thickness : hint_range(0.01, 1.0) = 0.02;

void fragment() {
	// apply color from sprite modulate property
	ALBEDO = COLOR.rgb;
	
	// offset depth to prevent z-fighting
	DEPTH = FRAGCOORD.z - 1e-5;
	
	// calculate distance to vertex center in world frame
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float dist = distance(world_pos, NODE_POSITION_WORLD);
	if(dist < radius + thickness / 2.0 && dist > radius - thickness / 2.0) {
		ALPHA = COLOR.a;
	} else {
		ALPHA = 0.0;
	}
}