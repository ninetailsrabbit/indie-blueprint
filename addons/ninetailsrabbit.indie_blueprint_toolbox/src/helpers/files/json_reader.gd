class_name IndieBlueprintJSONHelper


static func parse(path: String, encrypted_key: String = "") -> Variant:
	if not path.get_extension() == "json":
		push_error("IndieBlueprintJSONHelper: The file path %s provided does not have a valid JSON extension" % path)
		return {}
	
	var file: FileAccess
	
	if encrypted_key.is_empty():
		file = FileAccess.open(path, FileAccess.READ)
	else:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encrypted_key)
		
	var open_error: Error = FileAccess.get_open_error()
	
	if open_error != OK:
		push_error("IndieBlueprintJSONHelper: An error happened opening json file %s, Error %d-%s" % [path, open_error, error_string(open_error)])
		return {}
	
	var json = JSON.new()
	var json_string_data: String = file.get_as_text()
	var json_error: Error = json.parse(json_string_data)
	
	if json_error == OK:
		assert(json.data is Array or json.data is Dictionary, "IndieBlueprintJSONHelper: Invalid data type, only JSON dictionary or arrays are supported")
	else:
		push_error("IndieBlueprintJSONHelper: JSON Parse Error: ", json.get_error_message(), " in ", json_string_data, " at line ", json.get_error_line())

	return json.data
