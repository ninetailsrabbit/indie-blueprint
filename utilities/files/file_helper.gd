class_name FileHelper


static func filepath_is_valid(path: String) -> bool:
	return not path.is_empty() and path.is_absolute_path() and ResourceLoader.exists(path)


static func dirpath_is_valid(path: String) -> bool:
	return not path.is_empty() and path.is_absolute_path() and DirAccess.dir_exists_absolute(path)


static func directory_exist_on_executable_path(directory_path: String) -> bool:
	var real_path = OS.get_executable_path().get_base_dir().path_join(directory_path)
	var directory = DirAccess.open(real_path)
	
	if directory == null:
		return false
	
	return true
	
## Supports RegEx expressions
static func get_files_recursive(path: String, regex: RegEx = null) -> Array:
	if path.is_empty() or not DirAccess.dir_exists_absolute(path):
		push_error("FileHelper>get_files_recursive: directory not found '%s'" % path)

		return []

	var files = []
	var directory = DirAccess.open(path)
	
	if directory:
		directory.list_dir_begin()
		var file := directory.get_next()
		
		while file != "":
			if directory.current_is_dir():
				files += get_files_recursive(directory.get_current_dir().path_join(file), regex)
			else:
				var file_path = directory.get_current_dir().path_join(file)
				
				if regex != null:
					if regex.search(file_path):
						files.append(file_path)
				else:
					files.append(file_path)
					
			file = directory.get_next()
			
		return files
	else:
		push_error("FileHelper->get_files_recursive: An error %s occured when trying to open directory: %s" % [DirAccess.get_open_error(), path])
		
		return []


static func copy_directory_recursive(from_dir :String, to_dir :String) -> Error:
	if not DirAccess.dir_exists_absolute(from_dir):
		push_error("FileHelper->copy_directory_recursive: directory not found '%s'" % from_dir)
		return ERR_DOES_NOT_EXIST
		
	if not DirAccess.dir_exists_absolute(to_dir):
		
		var err := DirAccess.make_dir_recursive_absolute(to_dir)
		if err != OK:
			push_error("FileHelper->copy_directory_recursive: Can't create directory '%s'. Error: %s" % [to_dir, error_string(err)])
			return err
			
	var source_dir := DirAccess.open(from_dir)
	var dest_dir := DirAccess.open(to_dir)
	
	if source_dir != null:
		source_dir.list_dir_begin()
		var next := "."

		while next != "":
			next = source_dir.get_next()
			if next == "" or next == "." or next == "..":
				continue
			var source := source_dir.get_current_dir() + "/" + next
			var dest := dest_dir.get_current_dir() + "/" + next
			
			if source_dir.current_is_dir():
				copy_directory_recursive(source + "/", dest)
				continue
				
			var err := source_dir.copy(source, dest)
			
			if err != OK:
				push_error("FileHelper->copy_directory_recursive: Error checked copy file '%s' to '%s'" % [source, dest])
				return err
				
		return OK
	else:
		push_error("FileHelper->copy_directory_recursive: Directory not found: " + from_dir)
		return ERR_DOES_NOT_EXIST


static func remove_files_recursive(path: String, regex: RegEx = null) -> Error:
	var directory = DirAccess.open(path)
	
	if DirAccess.get_open_error() == OK:
		directory.list_dir_begin()
		
		var file_name = directory.get_next()
		
		while file_name != "":
			if directory.current_is_dir():
				remove_files_recursive(directory.get_current_dir().path_join(file_name), regex)
			else:
				if regex != null:
					if regex.search(file_name):
						directory.remove(file_name)
				else:
					directory.remove(file_name)
					
			file_name = directory.get_next()
		
		directory.remove(path)
		
		return OK
	else:
		var error := DirAccess.get_open_error()
		push_error("FileHelper->remove_recursive: An error %s happened open directory: %s " % [error_string(error), path])
		
		return error


static func get_pck_files(path: String) -> Array:
	var regex = RegEx.new()
	regex.compile(".pck$")
	
	return get_files_recursive(path, regex)


### CSV & TSV related ###
static func load_csv(path: String, as_dictionary := true):
	var file_exists := FileAccess.file_exists(path)

	if not filepath_is_valid(path) or not file_exists:
		push_error("FileHelper: Failed to load CSV because file doesn't exist or is corrupted. Path: %s", path)
		return ERR_PARSE_ERROR
		
	var delimiter = _detect_limiter_from_file(path)
	var lines := []
	
	var file := FileAccess.open(path, FileAccess.READ)
	var open_error := FileAccess.get_open_error()
	
	if open_error != Error.OK:
		push_error("FileHelper: ERROR_CODE[%s] Error opening file %s" % [error_string(open_error), path])
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
				push_error("FileHelper: Reading the file %s it was detected a line that has more fields than column headers [] < []" % [path, column_headers.join(","), current_fields.join(",")])
				return ERR_PARSE_ERROR
			
			for header_index in column_headers.size():
				current_dict[column_headers[header_index]] = current_fields[header_index] if header_index < current_fields.size() else null
				
			result_as_array_of_dictionaries.append(current_dict)
		
		return result_as_array_of_dictionaries
			
	return lines

	
static func _detect_limiter_from_file(filename: String) -> String:
	match filename.get_extension().to_lower():
		"csv":
			return ","
		"tsv":
			return "\t"
			
	return ","
