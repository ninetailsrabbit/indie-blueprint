class_name PauseMenu extends Control

@export var open_input_action: StringName = InputControls.PauseGame

@onready var back_button: MenuBackButton = %BackButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_game_button: Button = %QuitGameButton

@onready var settings_menu: SettingsMenu = $SettingsMenu
@onready var save_name_label: Label = %SaveName


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(open_input_action):
		visible = !visible
		

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	z_index = 1000
	
	hide()
	settings_menu.hide()
	settings_menu.z_index = z_index + 1

	save_name_label.text = SaveManager.current_saved_game.display_name if SaveManager.current_saved_game else ""
	
	SaveManager.created_savegame.connect(on_loaded_savegame)
	SaveManager.loaded_savegame.connect(on_loaded_savegame)
	
	settings_menu.visibility_changed.connect(on_settings_menu_visibility_changed)
	settings_button.pressed.connect(on_settings_button_pressed)
	quit_game_button.pressed.connect(on_quit_game_button_pressed)
	visibility_changed.connect(on_pause_menu_visibility_changed)
	
	
func on_pause_menu_visibility_changed() -> void:
	if visible:
		settings_button.grab_focus()
		
	get_tree().paused = visible


func on_loaded_savegame(saved_game: SavedGame) -> void:
	save_name_label.text = saved_game.display_name


func on_settings_menu_visibility_changed() -> void:
	await get_tree().physics_frame
	
	if settings_menu.visible:
		back_button.disable()
	else:
		back_button.enable()


func on_settings_button_pressed() -> void:
	settings_menu.show()
	

func on_quit_game_button_pressed() -> void:
	get_tree().quit()
	
