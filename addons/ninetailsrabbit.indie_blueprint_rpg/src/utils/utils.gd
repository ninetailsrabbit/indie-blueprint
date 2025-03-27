class_name IndieBlueprintRpgUtils

@warning_ignore("narrowing_conversion")
static func layer_to_value(layer: int) -> int:
	if layer > 32:
		push_error("IndieBlueprintRpgUtils->layer_to_value: The specified collision layer (%d) is invalid. Please ensure the layer value is between 1 and 32" % layer)
	
	return pow(2, clampi(layer, 1, 32) - 1)

@warning_ignore("narrowing_conversion")
static func value_to_layer(value: int) -> int:
	if value == 1:
		return value
		
	## This bitwise operation check if the value is a valid base 2
	if value > 0 and (value & (value - 1)) == 0:
		return (log(value) / log(2)) + 1
	
	push_error("IndieBlueprintRpgUtils->value_to_layer: The specified value %d) is invalid. Please ensure the value is a power of 2" % value)
	
	return 0


static func is_mouse_visible() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_VISIBLE || Input.mouse_mode == Input.MOUSE_MODE_CONFINED
