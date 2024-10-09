class_name VsyncCheckbox extends CheckBox

###
# Enable Vsync can be a good thing as it fixes screen tearing + it reduces your GPUs power usage
# but can cause input delays.
# When Vsync is disabled, will start drawing loads and loads of unnecessary frames which can be very taxing on power.
# This shouldn't be a problem for some games but can be very unnecessary power usage for 2D games or 3D games with low poly art style, like yours. 
# You can mitigate this by going to project settings and searching for "Max FPS". This will be 0 by default. Set it to something like 300
###

func _ready() -> void:
	button_pressed = int(DisplayServer.window_get_vsync_mode()) > 0
	toggled.connect(on_vsync_changed)


func on_vsync_changed(vsync_enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(int(vsync_enabled))
	
	SettingsManager.update_graphics_section(GameSettings.VsyncSetting, DisplayServer.window_get_vsync_mode())
