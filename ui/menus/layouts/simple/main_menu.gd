extends CanvasLayer


@onready var version_label: Label = %VersionLabel
@onready var title_label: Label = %TitleLabel

@onready var start_game_button: Button = %StartGameButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var exit_game_button: Button = %ExitGameButton


	
func _ready() -> void:
	version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	
	start_game_button.focus_neighbor_top = exit_game_button.get_path()
	exit_game_button.focus_neighbor_bottom = start_game_button.get_path()
	start_game_button.grab_focus()
	
	exit_game_button.pressed.connect(on_exit_game_button_pressed)


#region Signal callbacks
func on_exit_game_button_pressed() -> void:
	get_tree().quit()


#endregion
