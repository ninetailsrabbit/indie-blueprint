class_name FirstPersonTest extends CharacterBody3D


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		switch_mouse_capture_mode()


func _ready() -> void:
	InputHelper.capture_mouse()


func switch_mouse_capture_mode() -> void:
	if InputHelper.is_mouse_visible():
		InputHelper.capture_mouse()
	else:
		InputHelper.show_mouse_cursor()
