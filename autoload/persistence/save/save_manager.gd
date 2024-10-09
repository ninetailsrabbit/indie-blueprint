extends Node

signal created_savegame(filename: String)
signal loaded_savegame(filename: String)
signal removed_saved_game(filename: String)
signal error_creating_savegame(filename: String, error: Error)
signal error_loading_savegame(filename: String, error: Error)
signal error_removing_savegame(filename: String, error: Error)

## Dictionary<string, SavedGame>
@export var list_of_saved_games: Dictionary = {}
@export var current_saved_game: SavedGame:
	set(value):
		if value != current_saved_game:
			current_saved_game = value
			
			if current_saved_game:
				loaded_savegame.emit(current_saved_game.filename)


func _ready() -> void:
	list_of_saved_games.merge(read_user_saved_games(), true)


func create_new_save(filename: String, make_current: bool = false):
	if SavedGame.save_exists(filename):
		error_creating_savegame.emit(filename, ERR_ALREADY_EXISTS)
		return

	var new_saved_game = SavedGame.new()
	var error: Error = new_saved_game.write_savegame(filename)
	
	if error == Error.OK:
		created_savegame.emit(filename)
		list_of_saved_games[filename] = new_saved_game
		
		if make_current:
			current_saved_game = new_saved_game
	else:
		error_creating_savegame.emit(filename, error)


func load_savegame(filename: String) -> SavedGame:
	if SavedGame.save_exists(filename):
		return ResourceLoader.load(SavedGame.get_save_path(filename), "", ResourceLoader.CACHE_MODE_IGNORE) as SavedGame
		
	error_loading_savegame.emit(filename, ERR_DOES_NOT_EXIST)
	
	return null


func remove(filename: String):
	if list_of_saved_games.is_empty():
		return
		
	if (list_of_saved_games.has(filename)):
		var saved_game: SavedGame = list_of_saved_games[filename] as SavedGame
		saved_game.delete()
		
		list_of_saved_games.erase(filename)
		removed_saved_game.emit(filename)
		
		return
	
	push_error("SaveManager: Trying to remove a saved game with name %s that does not exists in the list of saved games" % filename)
	
	error_removing_savegame.emit(filename, ERR_DOES_NOT_EXIST)


func read_user_saved_games() -> Dictionary:
	var saved_games := {}
	var dir = DirAccess.open(SavedGame.default_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in [SavedGame.extension_on_save()]:
				var saved_game = load_savegame(file_name.get_basename())
				
				if saved_game: 
					saved_games[saved_game.filename] = saved_game
		
			file_name = dir.get_next()
					
		dir.list_dir_end()
		
	return saved_games
	
	
func saved_game_exists(saved_game: SavedGame) -> bool:
	if list_of_saved_games.is_empty():
		return false

	return list_of_saved_games.values().has(saved_game)
	

func save_filename_exists(filename: String) -> bool:
	if list_of_saved_games.is_empty():
		return false
		
	var name_to_check: String = StringHelper.clean(filename.get_basename().to_lower().strip_edges())
	
	return list_of_saved_games.keys().has(name_to_check)
