extends Node

var cursor_display_timer: Timer
var temporary_display_time: float = 3.5
var last_cursor_texture: Texture2D

## Dictionary[Input.CursorShape, Texture2D]
var default_game_cursors_by_shape: Dictionary = {}


func _ready() -> void:
	cursor_display_timer = TimeHelper.create_idle_timer(temporary_display_time, false, true)
	cursor_display_timer.name = "CursorDisplayTimer"
	
	add_child(cursor_display_timer)
	cursor_display_timer.timeout.connect(on_cursor_display_timer_timeout)


func return_cursor_to_default(cursor_shape: Input.CursorShape = Input.CursorShape.CURSOR_ARROW) -> void:
	if default_game_cursors_by_shape.has(cursor_shape):
		change_cursor_to(default_game_cursors_by_shape[cursor_shape], cursor_shape)


func change_cursor_to(texture: Texture2D, cursor_shape: Input.CursorShape = Input.CursorShape.CURSOR_ARROW, save_last_texture: bool = true) -> void:
	Input.set_custom_mouse_cursor(texture, cursor_shape, texture.get_size() / 2)
	
	if save_last_texture:
		last_cursor_texture = texture
	

func change_cursor_temporary_to(texture: Texture2D, cursor_shape: Input.CursorShape = Input.CursorShape.CURSOR_ARROW, duration: float = temporary_display_time) -> void:
	cursor_display_timer.start(duration)
	change_cursor_to(texture, cursor_shape, false)


func show_mouse() -> void:
	InputHelper.show_mouse_cursor()
	

func hide_mouse() -> void:
	InputHelper.hide_mouse_cursor()


func capture_mouse() -> void:
	InputHelper.capture_mouse()


func switch_mouse_capture_mode() -> void:
	if InputHelper.is_mouse_visible():
		capture_mouse()
	else:
		show_mouse()
	

func on_cursor_display_timer_timeout() -> void:
	change_cursor_to(last_cursor_texture)
	
