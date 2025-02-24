extends Control

signal fade_in_started(color_rect: ColorRect)
signal fade_in_finished(color_rect: ColorRect, fade_out: bool)
signal fade_out_started(color_rect: ColorRect)
signal fade_out_finished(color_rect: ColorRect, fade_in: bool)

signal flash_started(flash_screen: ColorRect)
signal flash_finished(flash_screen: ColorRect)

signal frame_freezed_started
signal frame_freezed_finished

@export_group("Fade")
@export var default_fade_color: Color = Color("040404")
@export var default_fade_duration: float = 1.0
@export var default_z_index: int = 101
@export_group("Flash")
@export var default_flash_color: Color = Color.WHITE
@export var default_flash_duration: float = 0.2
@export_range(0, 255, 1) var default_flash_transparency: int = 255
@export_group("Frame freeze")
@export var default_frame_freeze_duration: float = 1.0
@export var default_frame_freeze_time_scale: float = 0.25
@export var default_scale_audio: bool = true

## Current active targets where where any effect is being applied
var current_targets: Array[Control] = []
var is_frame_freezing: bool = false


func _ready() -> void:
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

	fade_in_finished.connect(on_fade_in_finished)
	fade_out_finished.connect(on_fade_out_finished)
	
	frame_freezed_started.connect(on_frame_freeze_started)
	frame_freezed_finished.connect(on_frame_freeze_finished)


#region Fade effects
func fade_in_out(
	in_duration: float = default_fade_duration, 
	in_color: Color = default_fade_color,
	out_duration: float = 0.0, 
	out_color = null
	) -> void:
		
	var fade_screen: ColorRect = _create_color_rect()
	fade_screen.set_meta(&"out_duration", out_duration if out_duration > 0 else in_duration)
	fade_screen.set_meta(&"out_color", out_color if out_color else in_color)
	
	_fade_in(fade_screen, in_duration, in_color, true)
	

func fade_out_in(
	out_duration: float = default_fade_duration, 
	out_color: Color = default_fade_color,
	in_duration: float = 0.0, 
	in_color = null
	) -> void:
	
	var fade_screen: ColorRect = _create_color_rect()
	fade_screen.set_meta(&"in_duration", in_duration if in_duration > 0 else out_duration)
	fade_screen.set_meta(&"in_color", in_color if in_color else out_color)
	
	_fade_out(fade_screen, out_duration, out_color, true)
	
	
func _fade_in(
	color_rect: ColorRect = _create_color_rect(),
	duration: float = default_fade_duration,
	color: Color = default_fade_color,
	fade_out_on_finish: bool = false) -> ColorRect:

	color_rect.show()
	color_rect.color = color
	color_rect.modulate.a = 0.0
	
	current_targets.append(color_rect)
	fade_in_started.emit(color_rect)
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	tween.finished.connect(func(): 
		fade_in_finished.emit(color_rect, fade_out_on_finish), 
		CONNECT_ONE_SHOT)
	
	return color_rect
	
	
func _fade_out(
	color_rect: ColorRect,
	duration: float = default_fade_duration,
	color: Color = default_fade_color,
	fade_in_on_finish: bool = false) -> ColorRect:
		
	color_rect.show()
	color_rect.modulate.a = 1.0
	color_rect.color = color
	
	fade_out_started.emit(color_rect)
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0, duration)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	tween.finished.connect(func(): 
		fade_out_finished.emit(color_rect, fade_in_on_finish), 
		CONNECT_ONE_SHOT)
	
	return color_rect
#endregion

#region Screen flashes

func flash(
	color: Color = default_flash_color,
	duration: float = default_flash_duration,
	initial_transparency: int = default_flash_transparency
) -> ColorRect:
	var flash_screen: ColorRect = _create_color_rect()
	flash_screen.color = color
	flash_screen.modulate.a8 = clampi(initial_transparency, 0, 255)
	flash_started.emit(flash_screen)
	
	var tween = create_tween()
	tween.tween_property(flash_screen, "modulate:a8", 0, duration)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	
	tween.finished.connect(func(): flash_finished.emit(flash_screen))
	
	return flash_screen


func flashes(
	colors: PackedColorArray = [],
	flash_duration: float = default_flash_duration, 
	initial_transparency: int = default_flash_transparency
) -> Array[ColorRect]:
	var flash_screens: Array[ColorRect] = [] 
	
	if colors.is_empty():
		return flash_screens
			
	for color: Color in colors:
		var flash_screen: ColorRect = _create_color_rect()
		flash_screens.append(flash_screen)
		flash_screen.color = color
		flash_screen.modulate.a8 = initial_transparency
		flash_screen.z_index = default_z_index - flash_screens.size()
		
	var tween: Tween = create_tween().set_parallel(true)
	
	for screen: ColorRect in flash_screens:
		flash_started.emit(screen)
		
		tween.chain().tween_property(screen, "modulate:a8", 0.0, flash_duration)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func(): flash_finished.emit(screen))
		
	tween.finished.connect(func():
		for screen: ColorRect in flash_screens:
			screen.queue_free()
		,CONNECT_ONE_SHOT)
		
	return flash_screens

#endregion


#region Time related
func frame_freeze(
	time_scale: float = default_frame_freeze_time_scale, 
	duration: float = default_frame_freeze_duration, 
	scale_audio: bool = default_scale_audio
) -> void:
	if is_frame_freezing:
		return
		
	frame_freezed_started.emit()
	
	var original_time_scale_value: float = Engine.time_scale
	var original_playback_speed_scale: float = AudioServer.playback_speed_scale
	
	Engine.time_scale = time_scale
	
	if scale_audio:
		AudioServer.playback_speed_scale = time_scale
	
	await get_tree().create_timer(duration, true, false, true).timeout
	
	Engine.time_scale = original_time_scale_value
	AudioServer.playback_speed_scale = original_playback_speed_scale
	
	frame_freezed_finished.emit()
#endregion


func _create_color_rect() -> ColorRect:
	var color_rect: ColorRect = ColorRect.new()
	color_rect.set_anchors_preset(PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.z_index = default_z_index + current_targets.size()
	
	add_child(color_rect)
	
	return color_rect
	
	
func _remove_color_rect(color_rect: ColorRect) -> void:
	current_targets.erase(color_rect)
	
	if not color_rect.is_queued_for_deletion():
		color_rect.queue_free()
		
		
#region Signal callbacks
func on_fade_in_finished(color_rect: ColorRect, fade_out_on_finish: bool) -> void:
	if fade_out_on_finish:
		_fade_out(color_rect, color_rect.get_meta(&"out_duration"), color_rect.get_meta(&"out_color"))
	else:
		_remove_color_rect(color_rect)


func on_fade_out_finished(color_rect: ColorRect, fade_in_on_finish: bool) -> void:
	if fade_in_on_finish:
		_fade_in(color_rect, color_rect.get_meta(&"in_duration"), color_rect.get_meta(&"in_color"))
	else:
		_remove_color_rect(color_rect)


func on_flash_finished(flash_screen: ColorRect) -> void:
	if not flash_screen.is_queued_for_deletion():
		flash_screen.queue_free()


func on_frame_freeze_started() -> void:
	is_frame_freezing = true


func on_frame_freeze_finished() -> void:
	is_frame_freezing = false
#endregion
