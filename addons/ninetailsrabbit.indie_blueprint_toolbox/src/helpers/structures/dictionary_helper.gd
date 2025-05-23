class_name IndieBlueprintDictionaryHelper


static func contain_all_keys(target: Dictionary, keys: Array[String]) -> bool:
	return keys.all(func(key: String): return key in target.keys())


static func contain_any_key(target: Dictionary, keys: Array[String]) -> bool:
	return keys.any(func(key: String): return key in target.keys())


static func reverse_key_value(source_dict: Dictionary) -> Dictionary:
	var reversed: Dictionary = {}
	
	for key in source_dict.keys():
		reversed[source_dict[key]] = key
	
	return reversed
	
## Transform the object used as dictionary key with the selected property, for example the object id
static func transform_dictionary_key(source_dict: Dictionary, property: String) -> Dictionary:
	var new_dict: Dictionary = {}
	
	if source_dict.is_empty():
		return source_dict
		
	for key: Object in source_dict:
		if key.has_method("get_property_list"):
			new_dict[key[property]] = source_dict[key]
	
	return new_dict
	

static func merge_recursive(dest: Dictionary, source: Dictionary) -> void:
	for key in source:
		if source[key] is Dictionary:
			
			if not dest.has(key):
				dest[key] = {}
				
			merge_recursive(dest[key], source[key])
		else:
			dest[key] = source[key]
