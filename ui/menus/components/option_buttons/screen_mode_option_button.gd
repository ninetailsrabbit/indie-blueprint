## Combine this class with the ScreenBorderlessCheckbox to include this option
class_name ScreenModeOptionButton extends OptionButton

var valid_window_modes: Array[DisplayServer.WindowMode] = [
	DisplayServer.WindowMode.WINDOW_MODE_WINDOWED,
	DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN,
	DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
]



func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():
			await ready

		prepare_screen_mode_items()


func _ready() -> void:
	prepare_screen_mode_items()
	select(get_item_index(DisplayServer.window_get_mode()))
	
	item_selected.connect(on_screen_mode_selected)


func prepare_screen_mode_items() -> void:
	clear()
	
	for mode in valid_window_modes:
		add_item(_screen_mode_to_string(mode), mode)
	

func _screen_mode_to_string(mode: DisplayServer.WindowMode) -> String:
	match mode:
		DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			return tr(TranslationKeys.WindowModeWindowedTranslationKey)
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			return tr(TranslationKeys.WindowModeFullScreenTranslationKey)
		DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			return tr(TranslationKeys.WindowModeExclusiveFullScreenTranslationKey)
		_:
			return tr(TranslationKeys.WindowModeWindowedTranslationKey)


func on_screen_mode_selected(idx) -> void:
	DisplayServer.window_set_mode(get_item_id(idx))
	SettingsManager.update_graphics_section(GameSettings.WindowDisplaySetting, DisplayServer.window_get_mode())
