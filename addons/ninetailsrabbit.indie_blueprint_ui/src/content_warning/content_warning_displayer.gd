class_name IndieBlueprintContentWarnings extends Control

signal content_warning_displayed(content_warning: IndieBlueprintContentWarning)
signal all_content_warnings_displayed

@export var input_action_skip_warning: StringName = &"ui_accept"
@export var content_warnings_to_display: Array[IndieBlueprintContentWarning] = []

@onready var content_warning_title: Label = %ContentWarningTitle
@onready var content_warning_subtitle: Label = %ContentWarningSubtitle
@onready var content_warning_description: RichTextLabel = %ContentWarningDescription
@onready var content_warning_secondary_description: RichTextLabel = %ContentWarningSecondaryDescription

var remaining_content_warnings: Array[IndieBlueprintContentWarning] = []
var current_content_warning: IndieBlueprintContentWarning
var display_tween: Tween


func _unhandled_input(_event: InputEvent) -> void:
	if InputMap.has_action(input_action_skip_warning) and Input.is_action_just_pressed(input_action_skip_warning):
		if current_content_warning and current_content_warning.can_be_skipped:
			display_tween.kill()
			content_warning_displayed.emit(current_content_warning)


func _enter_tree() -> void:
	content_warning_displayed.connect(on_content_warning_displayed)
	all_content_warnings_displayed.connect(on_all_content_warnings_displayed)


func _ready() -> void:
	hide_all_texts()
	
	if content_warnings_to_display.is_empty():
		all_content_warnings_displayed.emit()
	else:
		remaining_content_warnings = content_warnings_to_display.duplicate()
		display_content_warning(remaining_content_warnings.pop_front())
	
	
func display_content_warning(content_warning: IndieBlueprintContentWarning) -> void:
	set_process_unhandled_input(true)
	hide_all_texts()
	
	current_content_warning = content_warning
	
	content_warning_title.text = tr(content_warning.title_translation_key)
	content_warning_subtitle.text = tr(content_warning.subtitle_translation_key)
	content_warning_description.text = tr(content_warning.description_translation_key)
	content_warning_secondary_description.text = tr(content_warning.secondary_description_translation_key)
	
	display_tween = create_tween().set_parallel(true)
	
	display_tween.tween_property(content_warning_title, "modulate:a", 1.0, content_warning.time_to_display)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	display_tween.tween_property(content_warning_subtitle, "modulate:a", 1.0, content_warning.time_to_display)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	
	display_tween.chain()
	
	display_tween.tween_property(content_warning_description, "modulate:a", 1.0, content_warning.time_to_display / 2)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	display_tween.tween_property(content_warning_secondary_description, "modulate:a", 1.0, content_warning.time_to_display)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	
	await display_tween.finished
	await get_tree().create_timer(content_warning.time_on_screen).timeout
	
	hide_content_warning(content_warning)
	
	
func hide_content_warning(content_warning: IndieBlueprintContentWarning) -> void:
	display_tween = create_tween().set_parallel(true)
	
	display_tween.tween_property(content_warning_title, "modulate:a", 0, content_warning.time_to_hide)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	display_tween.tween_property(content_warning_subtitle, "modulate:a", 0, content_warning.time_to_hide)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		
	display_tween.tween_property(content_warning_description, "modulate:a", 0, content_warning.time_to_hide)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	display_tween.tween_property(content_warning_secondary_description, "modulate:a", 0, content_warning.time_to_hide)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		
	await display_tween.finished
		
	content_warning_displayed.emit(content_warning)
	
	
func hide_all_texts() -> void:
	content_warning_title.modulate.a = 0
	content_warning_subtitle.modulate.a = 0
	content_warning_description.modulate.a = 0
	content_warning_secondary_description.modulate.a = 0
	
	content_warning_title.text = ""
	content_warning_subtitle.text = ""
	content_warning_description.text = ""
	content_warning_secondary_description.text = ""


func on_content_warning_displayed(_content_warning: IndieBlueprintContentWarning):
	if remaining_content_warnings.is_empty():
		all_content_warnings_displayed.emit()
	else:
		display_content_warning(remaining_content_warnings.pop_front())


func on_all_content_warnings_displayed() -> void:
	set_process_unhandled_input(false)
	hide_all_texts()
	current_content_warning = null
