class_name IndieBlueprintThirdPersonController extends CharacterBody3D


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		switch_mouse_capture_mode()
		
		
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func switch_mouse_capture_mode() -> void:
	if IndieBlueprintInputHelper.is_mouse_visible():
		IndieBlueprintInputHelper.capture_mouse()
	else:
		IndieBlueprintInputHelper.show_mouse_cursor()
