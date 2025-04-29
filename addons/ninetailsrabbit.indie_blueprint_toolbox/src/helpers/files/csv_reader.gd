class_name IndieBlueprintCSVHelper


### CSV & TSV related ###
static func read(path: String, as_dictionary := true):
	var file_exists := FileAccess.file_exists(path)

	if not _filepath_is_valid(path) or not file_exists:
		push_error("IndieBlueprintCSVHelper: Failed to load CSV because file doesn't exist or is corrupted. Path: %s", path)
		return ERR_PARSE_ERROR
		
	var delimiter = _detect_limiter_from_file(path)
	var lines := []
	
	var file := FileAccess.open(path, FileAccess.READ)
	var open_error := FileAccess.get_open_error()
	
	if open_error != Error.OK:
		push_error("IndieBlueprintCSVHelper: ERROR_CODE[%s] Error opening file %s" % [error_string(open_error), path])
		return ERR_PARSE_ERROR

	while not file.eof_reached():
		var csv_line := file.get_csv_line(delimiter)
		var is_last_line := csv_line.size() == 0 || (csv_line.size() == 1 && csv_line[0].is_empty())
		
		if is_last_line:
			continue
		
		var parsed_line := []
		
		for field: String in csv_line:
			if field.is_valid_int():
				parsed_line.append(int(field))
			elif field.is_valid_float():
				parsed_line.append(float(field))
			else:
				parsed_line.append(field)

		lines.append(parsed_line)

	file.close()
	
	# Remove trailing empty line
	if not lines.is_empty() and lines.back().size() == 1 and lines.back()[0] == "":
		lines.pop_back()
		
	if as_dictionary and lines.size() > 1:
		var result_as_array_of_dictionaries := []
		var column_headers = lines[0]
		
		for i in range(1, lines.size()):
			var current_dict := {}
			var current_fields = lines[i]
			
			if current_fields.size() > column_headers.size():
				push_error("IndieBlueprintCSVHelper: Reading the file %s it was detected a line that has more fields than column headers [] < []" % [path, column_headers.join(","), current_fields.join(",")])
				return ERR_PARSE_ERROR
			
			for header_index in column_headers.size():
				current_dict[column_headers[header_index]] = current_fields[header_index] if header_index < current_fields.size() else null
				
			result_as_array_of_dictionaries.append(current_dict)
		
		return result_as_array_of_dictionaries
			
	return lines
	
	
static func _filepath_is_valid(path: String) -> bool:
	return not path.is_empty() and path.is_absolute_path() and ResourceLoader.exists(path)
	
	
static func _detect_limiter_from_file(filename: String) -> String:
	match filename.get_extension().to_lower():
		"csv":
			return ","
		"tsv":
			return "\t"
			
	return ","
