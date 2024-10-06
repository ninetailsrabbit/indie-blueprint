class_name DictionaryHelper


static func reverse_key_value(source_dict: Dictionary) -> Dictionary:
	var reversed := {}
	
	for key in source_dict.keys():
		reversed[source_dict[key]] = key
	
	return reversed
	
	
static func merge_recursive(dest: Dictionary, source: Dictionary) -> void:
	for key in source:
		if source[key] is Dictionary:
			if not dest.has(key):
				dest[key] = {}
			DictionaryHelper.merge_recursive(dest[key], source[key])
		else:
			dest[key] = source[key]
