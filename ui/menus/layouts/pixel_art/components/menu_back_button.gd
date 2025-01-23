class_name MenuBackButton extends Button

signal returned_back

@export var linked_menu: Control
@export var back_input_action: StringName = &"ui_cancel"


var is_enabled: bool = true


func _unhandled_input(_event: InputEvent) -> void:
	if is_enabled and visible and not back_input_action.is_empty() and Input.is_action_just_pressed(back_input_action):
		go_back()
		

func _ready() -> void:
	if linked_menu == null:
		linked_menu = get_parent()
	
	pressed.connect(on_pressed)


func enable() -> void:
	is_enabled = true


func disable() -> void:
	is_enabled = false


func go_back() -> void:
	if is_enabled and visible:
		linked_menu.hide()
		returned_back.emit()

	
func on_pressed() -> void:
	go_back()
