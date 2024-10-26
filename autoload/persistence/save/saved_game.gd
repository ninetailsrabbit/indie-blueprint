class_name SavedGame extends Resource

static var default_path: String = OS.get_user_data_dir()

@export var filename: String
@export var display_name: String
@export var version_control: String = ProjectSettings.get_setting("application/config/version", "1.0.0")
@export var engine_version: String = "Godot %s" % Engine.get_version_info().string
@export var device: String = OS.get_distribution_name()
@export var platform: String = OS.get_name()
@export var last_datetime := ""
@export var timestamp: float


func update_last_datetime():
	## Example { "year": 2024, "month": 1, "day": 25, "weekday": 4, "hour": 13, "minute": 34, "second": 18, "dst": false }
	var datetime = Time.get_datetime_dict_from_system()
	last_datetime = "%s/%s/%s %s:%s" % [str(datetime.day).pad_zeros(2), str(datetime.month).pad_zeros(2), datetime.year, str(datetime.hour).pad_zeros(2), str(datetime.minute).pad_zeros(2)]
	timestamp = Time.get_unix_time_from_system()



func write_savegame(new_filename: String = filename) -> Error:	
	if filename.is_empty():
		if new_filename.is_empty() or new_filename == null:
			push_error("SavedGame: To write this resource for the first time needs a valid filename [%s], the write operation was aborted" % new_filename)
			return ERR_CANT_CREATE
		
		display_name = new_filename
		filename = StringHelper.clean(new_filename.get_basename().to_lower().strip_edges())
		
	update_last_datetime()
	
	return ResourceSaver.save(self, SavedGame.get_save_path(filename))


func delete():
	if SavedGame.save_exists(filename):
		var error = DirAccess.remove_absolute(SavedGame.get_save_path(filename))
		
		if error != OK:
			push_error("An error happened trying to delete the file %s with code %s" % [filename, error_string(error)])


static func save_exists(_filename: String) -> bool:
	return ResourceLoader.exists(get_save_path(_filename))
	

static func get_save_path(_filename: String) -> String:
	return "%s/%s.%s" % [default_path, _filename.get_basename(), SavedGame.extension_on_save()]


static func extension_on_save() -> String:
	return "tres" if OS.is_debug_build() else "res"
