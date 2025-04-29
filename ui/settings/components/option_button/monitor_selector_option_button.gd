class_name MonitorSelectorOptionButton extends OptionButton


func _ready() -> void:
	for monitor in DisplayServer.get_screen_count():
		add_item("Monitor: " + str(monitor + 1), monitor)
	
	select(get_window().current_screen)
	
	item_selected.connect(on_monitor_selected)
	
	
func on_monitor_selected(idx: int) -> void:
	var window: Window = get_window()
	
	if idx < DisplayServer.get_screen_count() and idx != window.current_screen:
		window.current_screen = idx
		IndieBlueprintSettingsManager.update_graphics_section(IndieBlueprintGameSettings.CurrentMonitorSetting, window.current_screen)
