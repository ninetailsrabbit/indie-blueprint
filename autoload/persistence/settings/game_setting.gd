@tool
class_name GameSetting extends Resource

@export var section: StringName
@export var key: StringName
@export var field_type: Variant.Type:
	set(value):
		if value != field_type:
			field_type = value
			notify_property_list_changed()

@export_group("Int type")
@export var default_int_value: int
@export var int_value: int:
	set(value):
		int_value = clampi(value, min_int_value, max_int_value)
@export var min_int_value: int:
	set(value):
		min_int_value = mini(value, max_int_value) if value != 0 else value
@export var max_int_value: int:
	set(value):
		max_int_value = maxi(value, min_int_value) if value != 0 else value
		
@export_group("Float type")
@export var default_float_value: float
@export var float_value: float:
	set(value):
		float_value = clampf(value, min_float_value, max_float_value)
@export var min_float_value: float:
	set(value):
		min_float_value = min(value, max_float_value) if value != 0 else value
@export var max_float_value: float:
	set(value):
		max_float_value = maxf(value, min_float_value) if value != 0 else value
		
@export_group("Bool type")
@export var default_bool_value: bool = false
@export var bool_value: bool = false

@export_group("String type")
@export var default_string_value: String
@export var string_value: String

@export_group("StringName type")
@export var default_string_name_value: StringName
@export var string_name_value: StringName

@export_group("Array type")
@export var default_array_value: Array[Variant]
@export var array_value: Array[Variant]

@export_group("Dictionary type")
@export var default_dictionary_value: Dictionary
@export var dictionary_value: Dictionary

@export_group("Color type")
@export var default_color_value: Color
@export var color_value: Color

@export_group("Vector2 type")
@export var default_vector2_value: Vector2
@export var vector2_value: Vector2

@export_group("Vector2i type")
@export var default_vector2i_value: Vector2i
@export var vector2i_value: Vector2i

@export_group("Vector3 type")
@export var default_vector3_value: Vector3
@export var vector3_value: Vector3

@export_group("Vector3i type")
@export var default_vector3i_value: Vector3i
@export var vector3i_value: Vector3i


func reset_to_default() -> void:
	int_value = default_int_value
	float_value = default_float_value
	bool_value = default_bool_value
	string_value = default_string_value
	string_name_value = default_string_name_value
	array_value = default_array_value.duplicate()
	dictionary_value = default_dictionary_value.duplicate()
	color_value = default_color_value
	vector2_value = default_vector2_value
	vector2i_value = default_vector2i_value
	vector3_value = default_vector3_value
	vector3i_value = default_vector3i_value


func value() -> Variant:
	match field_type:
		TYPE_INT:
			return int_value
		TYPE_FLOAT:
			return float_value
		TYPE_BOOL:
			return bool_value
		TYPE_STRING:
			return string_value
		TYPE_STRING_NAME:
			return string_name_value
		TYPE_ARRAY:
			return array_value
		TYPE_DICTIONARY:
			return dictionary_value
		TYPE_COLOR:
			return color_value
		TYPE_VECTOR2:
			return vector2_value
		TYPE_VECTOR2I:
			return vector2i_value
		TYPE_VECTOR3:
			return vector3_value
		TYPE_VECTOR3I:
			return vector3i_value
		_:
			return null


func default_value() -> Variant:
	match field_type:
		TYPE_INT:
			return default_int_value
		TYPE_FLOAT:
			return default_float_value
		TYPE_BOOL:
			return default_bool_value
		TYPE_STRING:
			return default_string_value
		TYPE_STRING_NAME:
			return default_string_name_value
		TYPE_ARRAY:
			return default_array_value
		TYPE_DICTIONARY:
			return default_dictionary_value
		TYPE_COLOR:
			return default_color_value
		TYPE_VECTOR2:
			return default_vector2_value
		TYPE_VECTOR2I:
			return default_vector2i_value
		TYPE_VECTOR3:
			return default_vector3_value
		TYPE_VECTOR3I:
			return default_vector3i_value
		_:
			return null
			
			
func update_value(new_value: Variant) -> void:
	match field_type:
		TYPE_INT:
			int_value = new_value
		TYPE_FLOAT:
			float_value = new_value
		TYPE_BOOL:
			bool_value = new_value
		TYPE_STRING:
			string_value = new_value
		TYPE_STRING_NAME:
			string_name_value = new_value
		TYPE_ARRAY:
			array_value = new_value
		TYPE_DICTIONARY:
			dictionary_value = new_value
		TYPE_COLOR:
			color_value = new_value
		TYPE_VECTOR2:
			vector2_value = new_value
		TYPE_VECTOR2I:
			vector2i_value = new_value
		TYPE_VECTOR3:
			vector3_value = new_value
		TYPE_VECTOR3I:
			vector3i_value = new_value


func _validate_property(property: Dictionary):
	if property.name in ["default_int_value", "int_value", "min_int_value", "max_int_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_INT else PROPERTY_USAGE_READ_ONLY
	
	elif property.name in ["default_float_value", "float_value", "min_float_value", "max_float_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_FLOAT else PROPERTY_USAGE_READ_ONLY
	
	elif property.name in ["default_bool_value", "bool_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_BOOL else PROPERTY_USAGE_READ_ONLY

	elif property.name in ["default_string_value", "string_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_STRING else PROPERTY_USAGE_READ_ONLY
	
	elif property.name in ["default_string_name_value", "string_name_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_STRING_NAME else PROPERTY_USAGE_READ_ONLY
	
	elif property.name in ["default_array_value", "array_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_ARRAY else PROPERTY_USAGE_READ_ONLY

	elif property.name in ["default_dictionary_value", "dictionary_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_DICTIONARY else PROPERTY_USAGE_READ_ONLY
	
	elif property.name in ["default_color_value", "color_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_COLOR else PROPERTY_USAGE_READ_ONLY
	
	elif property.name in ["default_vector2_value", "vector2_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_VECTOR2 else PROPERTY_USAGE_READ_ONLY
	
	elif property.name in ["default_vector2i_value", "vector2i_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_VECTOR2I else PROPERTY_USAGE_READ_ONLY

	elif property.name in ["default_vector3_value", "vector3_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_VECTOR3 else PROPERTY_USAGE_READ_ONLY

	elif property.name in ["default_vector3i_value", "vector3i_value"]:
		property.usage |= PROPERTY_USAGE_DEFAULT if field_type == TYPE_VECTOR3I else PROPERTY_USAGE_READ_ONLY
