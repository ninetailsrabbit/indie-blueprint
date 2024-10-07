extends Node

var cursor_display_timer: Timer
var temporary_display_time: float = 3.5
var last_cursor_texture: Texture2D

## Dictoinary[Input.CursorShape, Texture2D]
var default_game_cursors_by_shape: Dictionary = {}


func _ready() -> void:
	cursor_display_timer = Timer.new()
	cursor_display_timer.name = "CursorDisplayTimer"
	cursor_display_timer.wait_time = temporary_display_time
	cursor_display_timer.autostart = false
	cursor_display_timer.one_shot = true
	
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


func on_cursor_display_timer_timeout() -> void:
	change_cursor_to(last_cursor_texture)
	
