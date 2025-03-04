extends Node

signal created_savegame(saved_game: IndieBlueprintSavedGame)
signal loaded_savegame(saved_game: IndieBlueprintSavedGame)
signal removed_saved_game(saved_game: IndieBlueprintSavedGame)
signal error_creating_savegame(filename: String, error: Error)
signal error_loading_savegame(filename: String, error: Error)
signal error_removing_savegame(filename: String, error: Error)

## Dictionary<string, IndieBlueprintSavedGame>
@export var list_of_saved_games: Dictionary = {}
@export var current_saved_game: IndieBlueprintSavedGame:
	set(value):
		if value != current_saved_game:
			current_saved_game = value
			
			if current_saved_game:
				loaded_savegame.emit(current_saved_game)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if current_saved_game:
			current_saved_game.write_savegame()
		
		
func _ready() -> void:
	list_of_saved_games.merge(read_user_saved_games(), true)


func make_current(saved_game: IndieBlueprintSavedGame) -> void:
	current_saved_game = saved_game


func create_new_save(filename: String, make_it_as_current: bool = false):
	if IndieBlueprintSavedGame.save_exists(filename):
		error_creating_savegame.emit(filename, ERR_ALREADY_EXISTS)
		return

	var new_saved_game = IndieBlueprintSavedGame.new()
	var error: Error = new_saved_game.write_savegame(filename)
	
	if error == Error.OK:
		list_of_saved_games[filename] = new_saved_game
		created_savegame.emit(new_saved_game)
		
		if make_it_as_current:
			make_current(new_saved_game)
	else:
		error_creating_savegame.emit(filename, error)


func load_savegame(filename: String) -> IndieBlueprintSavedGame:
	if IndieBlueprintSavedGame.save_exists(filename):
		return ResourceLoader.load(IndieBlueprintSavedGame.get_save_path(filename), "", ResourceLoader.CACHE_MODE_IGNORE) as IndieBlueprintSavedGame
		
	error_loading_savegame.emit(filename, ERR_DOES_NOT_EXIST)
	
	return null


func remove(filename: String):
	if list_of_saved_games.is_empty():
		return
		
	if (list_of_saved_games.has(filename)):
		var saved_game: IndieBlueprintSavedGame = list_of_saved_games[filename]
		removed_saved_game.emit(saved_game)
		
		saved_game.delete()
		
		list_of_saved_games.erase(filename)
		
		return
	
	push_error("IndieBlueprintSaveManager: Trying to remove a saved game with name %s that does not exists in the list of saved games" % filename)
	
	error_removing_savegame.emit(filename, ERR_DOES_NOT_EXIST)


func read_user_saved_games() -> Dictionary:
	DirAccess.make_dir_absolute(IndieBlueprintSavedGame.default_path)
	
	var saved_games: Dictionary= {}
	var dir: DirAccess = DirAccess.open(IndieBlueprintSavedGame.default_path)
	var dir_open_error: Error = DirAccess.get_open_error()
	
	if dir_open_error != OK:
		push_error("IndieBlueprintSaveManager: An error %s ocurred trying to open the folder in path %s " % [error_string(dir_open_error), IndieBlueprintSavedGame.default_path])
		return saved_games
		
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.get_extension() in [IndieBlueprintSavedGame.extension_on_save()]:
			var saved_game = load_savegame(file_name.get_basename())
			
			if saved_game: 
				saved_games[saved_game.filename] = saved_game
	
		file_name = dir.get_next()
				
	dir.list_dir_end()
		
	return saved_games
	
	
func saved_game_exists(saved_game: IndieBlueprintSavedGame) -> bool:
	if list_of_saved_games.is_empty():
		return false

	return list_of_saved_games.values().has(saved_game)
	

func save_filename_exists(filename: String) -> bool:
	if list_of_saved_games.is_empty():
		return false
		
	var name_to_check: String = IndieBlueprintSavedGame.clean_filename(filename.get_basename().to_lower().strip_edges())
	
	return list_of_saved_games.keys().has(name_to_check)
