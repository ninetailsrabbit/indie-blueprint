class_name InputActionKeybindingDisplay extends HBoxContainer

@onready var action_label: Label = $ActionLabel
@onready var input_key_label: Label = $InputKeyPanel/MarginContainer/InputKeyLabel
@onready var input_key_panel: Panel = $InputKeyPanel


var action: StringName = &""
var keybinding: InputEvent = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():
			await ready
		
		display_keybindings()


func setup(_action: StringName, _keybinding: InputEvent) -> void:
	action = _action
	keybinding = _keybinding
	
	display_keybindings()


func display_keybindings() -> void:
	if not action.is_empty() and keybinding:
		action_label.text = tr(action.to_upper())
		input_key_label.text = keybinding.as_text().replace("(Physical)", "").strip_edges()


func update_keybinding(new_event: InputEvent) -> void:
	InputMap.action_erase_event(action, keybinding)
	InputMap.action_add_event(action, new_event)
	
	keybinding = new_event
	display_keybindings()
	
	SettingsManager.create_keybinding_events_for_action(action)


func change_to_remapping_text() -> void:
	input_key_label.text = "Waiting for input..."
