class_name IndieBlueprintFileHelper


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
		push_error("IndieBlueprintFileHelper>get_files_recursive: directory not found '%s'" % path)

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
		push_error("IndieBlueprintFileHelper->get_files_recursive: An error %s occured when trying to open directory: %s" % [DirAccess.get_open_error(), path])
		
		return []


static func copy_directory_recursive(from_dir :String, to_dir :String) -> Error:
	if not DirAccess.dir_exists_absolute(from_dir):
		push_error("IndieBlueprintFileHelper->copy_directory_recursive: directory not found '%s'" % from_dir)
		return ERR_DOES_NOT_EXIST
		
	if not DirAccess.dir_exists_absolute(to_dir):
		
		var err := DirAccess.make_dir_recursive_absolute(to_dir)
		if err != OK:
			push_error("IndieBlueprintFileHelper->copy_directory_recursive: Can't create directory '%s'. Error: %s" % [to_dir, error_string(err)])
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
				push_error("IndieBlueprintFileHelper->copy_directory_recursive: Error checked copy file '%s' to '%s'" % [source, dest])
				return err
				
		return OK
	else:
		push_error("IndieBlueprintFileHelper->copy_directory_recursive: Directory not found: " + from_dir)
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
		push_error("IndieBlueprintFileHelper->remove_recursive: An error %s happened open directory: %s " % [error_string(error), path])
		
		return error


static func get_pck_files(path: String) -> Array:
	var regex = RegEx.new()
	regex.compile(".pck$")
	
	return get_files_recursive(path, regex)


static func get_resource_files(path: String) -> Array:
	var regex = RegEx.new()
	regex.compile(".res$")
	
	return get_files_recursive(path, regex)


static func get_scene_files(path: String) -> Array:
	var regex = RegEx.new()
	regex.compile(".tscn$")
	
	return get_files_recursive(path, regex)


static func get_script_files(path: String) -> Array:
	var regex = RegEx.new()
	regex.compile(".gd$")
	
	return get_files_recursive(path, regex)


static func get_shader_files(path: String) -> Array:
	var regex = RegEx.new()
	regex.compile(".gdshader$")
	
	return get_files_recursive(path, regex)
