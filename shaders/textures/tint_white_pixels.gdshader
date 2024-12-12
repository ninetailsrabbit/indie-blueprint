shader_type canvas_item;

void fragment() {
	vec4 rgba = texture(TEXTURE, UV); // The current pixel
    vec4 chosen_color = vec4(0.0, 1.0, 0.0, 1.0); // Change this to the desired color (this is green)
	
    float white_threshold = 0.95;

    /// Here you verify the white spectrum on the pixel
    if (rgba.r >= white_threshold && rgba.g >= white_threshold && rgba.b >= white_threshold) {
		rgba = chosen_color;
	}
    
	COLOR = rgba;
}
