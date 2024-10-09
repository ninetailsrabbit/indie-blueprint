extends HBoxContainer

@onready var action_label: Label = $ActionLabel
@onready var input_key_label: Label = $InputKeyPanel/MarginContainer/InputKeyLabel

var action: StringName = &""
var keybinding: InputEvent = null



func setup(_action: StringName, _keybinding: InputEvent) -> void:
	action = _action
	keybinding = _keybinding
	
	action_label.text = tr(action.to_upper())
	input_key_label.text = keybinding.as_text()
