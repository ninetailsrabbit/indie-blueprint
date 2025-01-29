class_name NewSaveScreen extends Control

signal created_new_save(new_save: SavedGame)

@export var action_to_submit: StringName = &"ui_accept"

@onready var save_file_name_line_edit: LineEdit = %SaveFileNameLineEdit


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(action_to_submit):
		create_new_save()


func _ready() -> void:
	set_process_unhandled_input(visible)
	
	SaveManager.error_creating_savegame.connect(on_error_creating_save_game)
	
	save_file_name_line_edit.visibility_changed.connect(on_visibility_changed)
	save_file_name_line_edit.text_changed.connect(on_text_changed)
	save_file_name_line_edit.text_submitted.connect(on_text_submitted)
	
	
func create_new_save() -> void:
	if filename_is_valid(save_file_name_line_edit.text):
		set_process_unhandled_input(false)
		save_file_name_line_edit.editable = false
		
		SaveManager.create_new_save(save_file_name_line_edit.text, true)
		
		created_new_save.emit(SaveManager.current_saved_game)
	
	
func filename_is_valid(filename: String) -> bool:
	var is_valid: bool = true
	
	for character: String in filename:
		if character in StringHelper.AsciiPunctuation:
			is_valid = false
			break
	
	if not is_valid:
		save_file_name_line_edit.text = filename.left(filename.length() - 1)
		save_file_name_line_edit.caret_column = save_file_name_line_edit.text.length()
	
	return is_valid


func on_text_changed(new_text: String) -> void:
	filename_is_valid(new_text)
		

func on_text_submitted(_filename: String) -> void:
	create_new_save()

@warning_ignore("unused_parameter")
func on_error_creating_save_game(filename: String, error: Error) -> void:
	pass


func on_visibility_changed() -> void:
	set_process_unhandled_input(visible)
	
	if visible:
		save_file_name_line_edit.grab_focus()
	else:
		save_file_name_line_edit.release_focus()
		save_file_name_line_edit.clear()
