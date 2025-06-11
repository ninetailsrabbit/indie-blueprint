class_name VsyncCheckbox extends SettingCheckbox

###
# Enable Vsync can be a good thing as it fixes screen tearing + it reduces your GPUs power usage
# but can cause input delays.
# When Vsync is disabled, will start drawing loads and loads of unnecessary frames which can be very taxing on power.
# This shouldn't be a problem for some games but can be very unnecessary power usage for 2D games or 3D games with low poly art style, like yours. 
# You can mitigate this by going to project settings and searching for "Max FPS". This will be 0 by default. Set it to something like 300
###

func _ready() -> void:
	super._ready()
	button_pressed = int(DisplayServer.window_get_vsync_mode()) > 0


func on_setting_changed(vsync_enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(int(vsync_enabled))
	IndieBlueprintSettingsManager.update_graphics_section(IndieBlueprintGameSettings.VsyncSetting, DisplayServer.window_get_vsync_mode())
