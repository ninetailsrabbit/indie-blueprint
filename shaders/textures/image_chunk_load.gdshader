// This Shader was shared from the creator of the game https://nartier.itch.io/voyager-19
shader_type canvas_item;

uniform float image_load_percent : hint_range(0.0, 1.0, 0.01);
uniform vec4 blank_color : source_color;
uniform int image_columns = 4;

void fragment() {
	int total_image_blocks = image_columns * image_columns;

	int x_pos = int(UV.x * float(image_columns));
	int y_pos = int(UV.y * float(image_columns));
	int current_index = y_pos * image_columns + x_pos;

	bool section_loaded = image_load_percent > float(current_index) / float(total_image_blocks);
	if (section_loaded)
		COLOR = texture(TEXTURE, UV);
	else
		COLOR = blank_color;
}