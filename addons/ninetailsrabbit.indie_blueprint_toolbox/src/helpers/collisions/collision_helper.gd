class_name IndieBlueprintCollisionHelper


@warning_ignore("narrowing_conversion")
static func layer_to_value(layer: int) -> int:
	if layer > 32:
		push_error("CollisionHelper->layer_to_value: The specified collision layer (%d) is invalid. Please ensure the layer value is between 1 and 32" % layer)
	
	return pow(2, clampi(layer, 1, 32) - 1)

@warning_ignore("narrowing_conversion")
static func value_to_layer(value: int) -> int:
	if value == 1:
		return value
		
	## This bitwise operation check if the value is a valid base 2
	if value > 0 and (value & (value - 1)) == 0:
		return (log(value) / log(2)) + 1
	
	push_error("CollisionHelper->value_to_layer: The specified value %d) is invalid. Please ensure the value is a power of 2" % value)
	
	return 0

## The -0.5 is used in the code, to ensure that the random point is evenly distributed within the shape.
static func get_random_point_from_collision_shape(collision: CollisionShape3D, use_global: bool = true) -> Vector3:
	var random_point_local: Vector3

	if collision.shape is BoxShape3D:
		random_point_local = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5) * collision.shape.size

	return collision.to_global(random_point_local) if use_global else random_point_local
