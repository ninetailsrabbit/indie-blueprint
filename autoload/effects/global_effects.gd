extends Control

signal frame_freezed_started
signal frame_freezed_finished
signal fade_started
signal fade_finished
signal flash_started
signal flash_finished(flash_screen: ColorRect)

@export_group("Fade")
@export var default_fade_color: Color = Color("040404")
@export var default_fade_duration: float = 1.0
@export_group("Frame freeze")
@export var default_frame_freeze_duration: float = 1.0
@export var default_frame_freeze_time_scale: float = 0.25
@export var default_scale_audio: bool = true

@onready var fade_background: ColorRect = $FadeBackground

var is_frame_freezing: bool = false
var is_fading: bool = false
var is_flashing: bool = false


func _ready() -> void:
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	
	
	fade_background.color = default_fade_color
	fade_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_background.z_index = 101
	fade_background.hide()
	
	fade_started.connect(on_fade_started)
	fade_finished.connect(on_fade_finished)
	
	
	frame_freezed_started.connect(on_frame_freeze_started)
	frame_freezed_finished.connect(on_frame_freeze_finished)
	

#region Fade effects
func fade_in(duration: float = default_fade_duration, color: Color = default_fade_color) -> void:
	if not is_fading:
		fade_started.emit()
		
		fade_background.show()
		fade_background.color = color
		fade_background.modulate.a = 0.0
		
		var tween = create_tween()
		tween.tween_property(fade_background, "modulate:a", 1.0, duration)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
		await tween.finished
		
		fade_finished.emit()


func fade_out(duration: float = default_fade_duration, color: Color = default_fade_color) -> void:
	if not is_fading:
		fade_started.emit()
		
		fade_background.show()
		fade_background.color = color
		fade_background.modulate.a = 1.0
		
		var tween = create_tween()
		tween.tween_property(fade_background, "modulate:a", 0, duration)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
		await tween.finished
		
		fade_finished.emit()
#endregion

#region Screen flashes

func flash(color: Color, duration: float = 1.0, initial_transparency: int = 255) -> void:
	flash_started.emit()
	var flash_screen_color: ColorRect = ColorRect.new()
	flash_screen_color.set_anchors_preset(PRESET_FULL_RECT)
	flash_screen_color.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_screen_color.z_index = 100
	flash_screen_color.color = color
	flash_screen_color.modulate.a8 = clamp(initial_transparency, 0, 255)
	add_child(flash_screen_color)
	
	var tween = create_tween()
	tween.tween_property(flash_screen_color, "modulate:a8", 0, duration)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	
	await tween.finished
	
	flash_finished.emit(flash_screen_color)
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

#region Signal callbacks
func on_fade_started() -> void:
	is_fading = true


func on_fade_finished() -> void:
	is_fading = false
	fade_background.hide()


func on_flash_started() -> void:
	is_flashing = true
	

func on_flash_finished(flash_screen: ColorRect) -> void:
	is_flashing = false
	
	if not flash_screen.is_queued_for_deletion():
		flash_screen.queue_free()


func on_frame_freeze_started() -> void:
	is_frame_freezing = true


func on_frame_freeze_finished() -> void:
	is_frame_freezing = false

#endregion
