class_name MainMenu extends Control

@onready var start_game_button: Button = %StartGameButton
@onready var settings_button: Button = %SettingsButton
@onready var feedback_button: Button = %FeedbackButton
@onready var quit_game_button: Button = %QuitGameButton

@onready var world_selection: Control = $WorldSelection
@onready var settings_menu: SettingsMenu = $SettingsMenu


func _ready() -> void:
	world_selection.hide()
	settings_menu.hide()
	
	start_game_button.grab_focus()
	
	start_game_button.pressed.connect(on_start_button_pressed)
	settings_button.pressed.connect(on_settings_button_pressed)
	feedback_button.pressed.connect(on_feedback_button_pressed)
	quit_game_button.pressed.connect(on_quit_button_pressed)
		
	
func on_start_button_pressed() -> void:
	world_selection.show()


func on_settings_button_pressed() -> void:
	settings_menu.show()
	world_selection.hide()
	

func on_feedback_button_pressed() -> void:
	NetworkHelper.open_external_link("") ## Link to discord or feedback form
	

func on_quit_button_pressed() -> void:
	get_tree().quit()
