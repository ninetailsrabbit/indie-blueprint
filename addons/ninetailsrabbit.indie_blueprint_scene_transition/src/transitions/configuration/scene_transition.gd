class_name IndieBlueprintSceneTransition extends Control

signal in_transition_started
signal in_transition_finished

signal out_transition_started
signal out_transition_finished

@export var default_z_index: int = 100


func transition_in(args: Dictionary = {}) -> void:
	pass
	
	
func transition_out(args: Dictionary = {}) -> void:
	pass



func prepare_color_rect(color_rect: ColorRect) -> ColorRect:
	color_rect.set_anchors_preset(PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.z_index = default_z_index
	
	return color_rect
