class_name ScreenModeOptionButton extends OptionButton

var valid_window_modes = [
	DisplayServer.WindowMode.WINDOW_MODE_WINDOWED,
	DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS,
	DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN,
	DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
]

## Borderless needs a different id to not overwrite the rest of window mode enums
var borderless_id = 5


func _ready() -> void:
	for mode in valid_window_modes:
		add_item(_screen_mode_to_string(mode), borderless_id if mode == DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS else mode)
	
	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS):
		select(get_item_index(borderless_id))
		
	else:
		select(get_item_index(DisplayServer.window_get_mode()))
	
	
	item_selected.connect(on_screen_mode_selected)


func _screen_mode_to_string(mode: DisplayServer.WindowMode) -> String:
	match mode:
		DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			return tr(TranslationKeys.WindowModeWindowedTranslationKey)
		DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS:
			return tr(TranslationKeys.WindowModeBorderlessTranslationKey)
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			return tr(TranslationKeys.WindowModeExclusiveFullScreenTranslationKey)
		DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			return tr(TranslationKeys.WindowModeExclusiveFullScreenTranslationKey)
		_:
			return tr(TranslationKeys.WindowModeWindowedTranslationKey)


func on_screen_mode_selected(idx) -> void:
	if get_item_id(idx) == borderless_id:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	else:
		DisplayServer.window_set_mode(get_item_id(idx))
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		
	SettingManager.update_graphics_section(GameSettings.WindowDisplaySetting, DisplayServer.window_get_mode())
	SettingManager.update_graphics_section(GameSettings.WindowDisplayBorderlessSetting, DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
