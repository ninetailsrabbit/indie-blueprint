class_name CollisionHelper


@warning_ignore("narrowing_conversion")
func layer_to_value(layer: int) -> int:
		return pow(2, clampi(layer, 1, 32) - 1)
