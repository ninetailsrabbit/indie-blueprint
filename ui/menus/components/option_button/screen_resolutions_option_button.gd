class_name ScreenResolutionsOptionButton extends OptionButton

## Make available only the resolutions that the user computer can handle
@export var use_computer_screen_resolution_limit = true
@export var display4_3: bool = false
@export var display16_9: bool = true
@export var display16_10: bool = false
@export var display21_9: bool = false
@export var display_mobile: bool = false


func _ready() -> void:
	item_selected.connect(on_resolution_selected)
	
	resolutions_based_on_hardware()
	_fill_available_resolutions()
	

func _fill_available_resolutions() -> void:
	var current_window_size: Vector2i =  DisplayServer.window_get_size() if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED else SettingsManager.get_graphics_section("resolution")
	
	for display_resolution in WindowManager.resolutions:
		if _resolution_is_included(display_resolution):
			add_separator(display_resolution)
			
			var allowed_resolutions =  WindowManager.resolutions[display_resolution].filter(func(screen_size): return screen_size <= HardwareDetector.computer_screen_size) if use_computer_screen_resolution_limit else WindowManager.resolutions[display_resolution] 
			
			for screen_size: Vector2i in allowed_resolutions:
				add_item("%dx%d" % [screen_size.x, screen_size.y])
				
				if current_window_size == screen_size:
					select(item_count - 1)
			

func resolutions_based_on_hardware() -> void:
	if (HardwareDetector.is_steam_deck()):
		display16_10 = true
		display16_9 = false
		display21_9 = false
		display4_3 = false
	elif HardwareDetector.is_mobile():
		display16_10 = false
		display16_9 = false
		display21_9 = false
		display4_3 = false
		display_mobile = true
		

func _resolution_is_included(resolution: String) -> bool:
	return resolution == WindowManager.Resolution4_3 && display4_3 \
		or resolution == WindowManager.Resolution16_9 && display16_9 \
		or resolution == WindowManager.Resolution16_10 && display16_10 \
		or resolution == WindowManager.Resolution21_9 && display21_9 \
		or resolution == WindowManager.Resolution_Mobile && display_mobile


func on_resolution_selected(idx) -> void:
	## We need to split the text to get the Vector2i as the options cannot be saved as Variants
	var resolution: PackedStringArray = get_item_text(idx).split("x")
	var screen_size = Vector2i(int(resolution[0]), int(resolution[1]))
	
	DisplayServer.window_set_size(screen_size)
	
	SettingsManager.update_graphics_section(GameSettings.WindowResolutionSetting, screen_size)
