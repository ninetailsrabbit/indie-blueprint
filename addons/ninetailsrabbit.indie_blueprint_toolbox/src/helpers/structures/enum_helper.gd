class_name IndieBlueprintEnumHelper


static func random_value(_enum: Variant) -> Variant:
	return _enum.keys()[randi() % _enum.size()]


static func random_value_as_str(_enum: Variant) -> StringName:
	return value_to_str(_enum, randi() % _enum.size())


static func value_to_str(_enum: Variant, value: int) -> StringName:
	return StringName(_enum.keys()[value])


static func values_to_str(_enum: Variant) -> Array[StringName]:
	var values: Array[StringName] = []
	
	for index: int in _enum.keys().size():
		values.append(value_to_str(_enum, index))

	return values
