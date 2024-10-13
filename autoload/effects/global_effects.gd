extends Control

signal frame_freezed_started
signal frame_freezed_finished
signal fade_started
signal fade_finished

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


func _ready() -> void:
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

	fade_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_background.modulate.a = 0
	
	fade_started.connect(on_fade_started)
	fade_finished.connect(on_fade_finished)
	frame_freezed_started.connect(on_frame_freeze_started)
	frame_freezed_finished.connect(on_frame_freeze_finished)
	

#region Fade effects
func fade_in(duration: float = default_fade_duration, color: Color = default_fade_color) -> void:
	if(not is_fading and fade_background.modulate.a == 0):
		fade_started.emit()
		
		fade_background.color = color
		var tween = create_tween()
		tween.tween_property(fade_background, "modulate:a", 1.0, duration)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
		await tween.finished
		
		fade_finished.emit()


func fade_out(duration: float = default_fade_duration, color: Color = default_fade_color) -> void:
	if(not is_fading and fade_background.modulate.a > 0):
		fade_started.emit()
		
		fade_background.color = color
		var tween = create_tween()
		tween.tween_property(fade_background, "modulate:a", 0, duration)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
		await tween.finished
		
		fade_finished.emit()
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


func on_frame_freeze_started() -> void:
	is_frame_freezing = true


func on_frame_freeze_finished() -> void:
	is_frame_freezing = false

#endregion
