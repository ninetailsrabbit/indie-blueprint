class_name IndieBlueprintColorHelper

const ColorPalettesPath: String = "res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/helpers/color/palettes"
const GradientsPath: String = "res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/helpers/color/gradients"

enum ColorGenerationMethod {
	RandomRGB,
	GoldenRatioHSV
}


static func get_palette(id: StringName) -> IndieBlueprintColorPalette:
	var regex = RegEx.new()
	regex.compile(".tres$")
	
	for color_palette_path: String in IndieBlueprintFileHelper.get_files_recursive(ColorPalettesPath, regex):
		var color_palette: IndieBlueprintColorPalette = ResourceLoader.load(color_palette_path, "", ResourceLoader.CACHE_MODE_REUSE)
		
		if color_palette.id == id:
			return color_palette
			
	return null



static func get_gradient(id: StringName) -> IndieBlueprintColorGradient:
	var regex = RegEx.new()
	regex.compile(".tres$")
	
	for gradient_path: String in IndieBlueprintFileHelper.get_files_recursive(GradientsPath, regex):
		var gradient: IndieBlueprintColorGradient = ResourceLoader.load(gradient_path, "", ResourceLoader.CACHE_MODE_REUSE)
		
		if gradient.id == id:
			return gradient
			
	return null


static func generate_random_colors(method: ColorGenerationMethod, number_of_colors: int = 12, saturation: float = 0.5, value: float = 0.95) -> PackedColorArray:
	var colors: PackedColorArray = PackedColorArray()
	
	match method:
		ColorGenerationMethod.RandomRGB:
			return generate_random_rgb_colors(number_of_colors)
		ColorGenerationMethod.GoldenRatioHSV:
			return generate_random_hsv_colors(number_of_colors, saturation, value)
		
	return colors
	
# Using ideas from https://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
static func generate_random_hsv_colors(number_of_colors: int = 12, saturation: float = 0.5, value: float = 0.95) -> PackedColorArray:
	var colors: PackedColorArray = PackedColorArray()
	
	for i: int in number_of_colors:
		var h = randf()
		h += IndieBlueprintMathHelper.GoldenRatioConjugate
		h = fmod(h, 1.0)
		
		colors.append(Color.from_hsv(h, saturation, value))
		
	return colors

# Using ideas from https://www.iquilezles.org/www/articles/palettes/palettes.htm
static func generate_random_rgb_colors(number_of_colors: int = 12, darkened_value: float = 0.2) -> PackedColorArray:
	var a = Vector3(randf_range(0.0, 0.5), randf_range(0.0, 0.5), randf_range(0.0, 0.5))
	var b = Vector3(randf_range(0.1, 0.6), randf_range(0.1, 0.6), randf_range(0.1, 0.6))
	var c = Vector3(randf_range(0.15, 0.8), randf_range(0.15, 0.8), randf_range(0.15, 0.8))
	var d = Vector3(randf_range(0.4, 0.6), randf_range(0.4, 0.6), randf_range(0.4, 0.6))

	var colors: PackedColorArray = PackedColorArray()
	var n: float = float(number_of_colors - 1.0)
	
	for i: int in number_of_colors:
		var vec3 = Vector3(
			(a.x + b.x * cos(TAU * (c.x * float(i / n) + d.x))) + (i / n),
			(a.y + b.y * cos(TAU * (c.y * float(i / n) + d.y))) + (i / n),
			(a.z + b.z * cos(TAU * (c.z * float(i / n) + d.z))) + (i / n)
		)
		
		colors.append(Color(vec3.x, vec3.y, vec3.z).darkened(darkened_value))

	return colors


## Consider exploring alternative color difference metrics like Delta-E or CIELAB if precise color matching is crucial
static func colors_are_similar(color_a: Color, color_b: Color, tolerance: float = 100.0) -> bool:
	var v1: Vector4 = Vector4(color_a.r, color_a.g, color_a.b, color_a.a)
	var v2: Vector4 = Vector4(color_b.r, color_b.g, color_b.b, color_b.a)

	return v2.distance_to(v1) <= (tolerance / 255.0)


static func color_from_vector(vec) -> Color:
	if vec is Vector3:
		return Color(vec.x, vec.y, vec.z)
	elif vec is Vector4:
		return Color(vec.x, vec.y, vec.z, vec.w)
	else:
		return Color.WHITE
