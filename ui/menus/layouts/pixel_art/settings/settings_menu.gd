class_name SettingsMenu extends Control

@onready var display_settings_menu: DisplaySettingsMenu = $DisplaySettingsMenu
@onready var audio_settings_menu: DisplaySettingsMenu = $AudioSettingsMenu
@onready var accessibility_settings_menu: Control = $AccessibilitySettingsMenu
@onready var controls_settings_menu: Control = $ControlSettingsMenu

@onready var display_settings_button: Button = %DisplaySettingsButton
@onready var audio_settings_button: Button = %AudioSettingsButton
@onready var accessibility_settings_button: Button = %AccessibilitySettingsButton
@onready var controls_settings_button: Button = %ControlsSettingsButton
@onready var back_button: MenuBackButton = $MarginContainer/BackButton


func _ready() -> void:
	if visible:
		display_settings_button.grab_focus()
		
	
	display_settings_button.pressed.connect(on_display_settings_pressed)
	audio_settings_button.pressed.connect(on_audio_settings_pressed)
	accessibility_settings_button.pressed.connect(on_accessibility_settings_pressed)
	controls_settings_button.pressed.connect(on_controls_settings_pressed)
	
	display_settings_menu.visibility_changed.connect(on_component_settings_menu_visibility_changed.bind(display_settings_menu))
	audio_settings_menu.visibility_changed.connect(on_component_settings_menu_visibility_changed.bind(audio_settings_menu))
	accessibility_settings_menu.visibility_changed.connect(on_component_settings_menu_visibility_changed.bind(accessibility_settings_menu))
	controls_settings_menu.visibility_changed.connect(on_component_settings_menu_visibility_changed.bind(controls_settings_menu))
	
	visibility_changed.connect(on_settings_menu_visibility_changed)
	

func all_menus_are_hidden() -> bool:
	return not display_settings_menu.visible \
		and not audio_settings_menu.visible \
		and not accessibility_settings_menu.visible \
		and not controls_settings_menu.visible


func on_component_settings_menu_visibility_changed(_settings_menu: Control) -> void:
	await get_tree().physics_frame
	
	if all_menus_are_hidden():
		back_button.enable()
	else:
		back_button.disable()


func on_settings_menu_visibility_changed() -> void:
	if visible:
		display_settings_button.grab_focus()


func on_display_settings_pressed() -> void:
	display_settings_menu.show()
	audio_settings_menu.hide()
	accessibility_settings_menu.hide()
	controls_settings_menu.hide()


func on_audio_settings_pressed() -> void:
	display_settings_menu.hide()
	audio_settings_menu.show()
	accessibility_settings_menu.hide()
	controls_settings_menu.hide()


func on_accessibility_settings_pressed() -> void:
	display_settings_menu.hide()
	audio_settings_menu.hide()
	accessibility_settings_menu.show()
	controls_settings_menu.hide()


func on_controls_settings_pressed() -> void:
	display_settings_menu.hide()
	audio_settings_menu.hide()
	accessibility_settings_menu.hide()
	controls_settings_menu.show()
