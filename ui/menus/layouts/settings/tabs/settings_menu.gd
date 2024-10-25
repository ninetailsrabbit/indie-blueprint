@icon("res://assets/node_icons/settings.svg")
extends Control


@onready var audio_tab_bar: TabBar = %Audio
@onready var screen_tab_bar: TabBar = %Screen
@onready var graphics_tab_bar: TabBar = %Graphics
@onready var general_tab_bar: TabBar = %General
@onready var controls_tab_bar: TabBar = %Controls
@onready var back_button: Button = %BackButton


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if is_node_ready():
			prepare_tab_bars()


func _ready() -> void:
	back_button.pressed.connect(on_back_button_pressed)
	
	prepare_tab_bars()


func prepare_tab_bars() -> void:
	audio_tab_bar.name = tr(TranslationKeys.AudioTabTranslationKey)
	screen_tab_bar.name = tr(TranslationKeys.ScreenTabTranslationKey)
	graphics_tab_bar.name = tr(TranslationKeys.GraphicsQualityTranslationKey)
	general_tab_bar.name = tr(TranslationKeys.GeneralTabTranslationKey)
	controls_tab_bar.name = tr(TranslationKeys.ControlsTabTranslationKey)


func on_back_button_pressed() -> void:
	if owner:
		hide()

	
