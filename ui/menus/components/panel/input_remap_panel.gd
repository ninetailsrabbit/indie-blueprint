extends Control

const InputActionKeybindingScene = preload("res://ui/menus/components/panel/input_action_keybinding.tscn")

@export var include_ui_actions: bool = false

@onready var action_list: VBoxContainer = %ActionListVboxContainer
@onready var reset_to_default_button: Button = $PanelContainer/MarginContainer/ActionListVboxContainer/ResetToDefaultButton

var is_remapping: bool = false
var current_action_to_remap: StringName = ""


func _ready() -> void:
	load_input_keybindings(_get_input_map_actions())
		
	reset_to_default_button.pressed.connect(on_reset_to_default_pressed)


func load_input_keybindings(target_actions: Array[StringName]) -> void:
	for action: StringName in target_actions:
		var actions: Array[InputEvent] = InputMap.action_get_events(action)
			
		if actions.size() > 0:
			var input_action_keybinding = InputActionKeybindingScene.instantiate()
			action_list.add_child(input_action_keybinding)
			input_action_keybinding.setup(action, actions[0])
			
	## Move the reset to default button to the end of the list
	action_list.move_child(reset_to_default_button, action_list.get_child_count() - 1)


func _get_input_map_actions() -> Array[StringName]:
	return InputMap.get_actions() if include_ui_actions else InputMap.get_actions().filter(func(action): return !action.contains("ui_"))


func on_reset_to_default_pressed() -> void:
	var default_input_map_actions: Dictionary = GameSettings.DefaultSettings[GameSettings.DefaultInputMapActionsSetting]
	print(default_input_map_actions)
	
	for action: StringName in default_input_map_actions:
		print(default_input_map_actions)
