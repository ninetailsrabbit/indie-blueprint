extends PanelContainer

const InputActionKeybindingScene = preload("res://ui/menus/components/panel/input_action_keybinding.tscn")

@export var include_ui_actions: bool = false
@export var exclude_actions: Array[String] = []
@onready var action_list: VBoxContainer = %ActionListVboxContainer
@onready var reset_to_default_button: Button = $MarginContainer/ActionListVboxContainer/ResetToDefaultButton

var is_remapping: bool = false:
	set(value):
		if value != is_remapping:
			is_remapping = value
			
			set_process_input(is_remapping)
			
var current_action_to_remap: InputActionKeybindingDisplay = null


func _input(event: InputEvent) -> void:
	## Only detects keyboards binding for now, gamepad support in the future
	if event is InputEventKey:
		accept_event()
		
		## Important line to accept modifiers when this are keep pressed
		if InputHelper.any_key_modifier_is_pressed() and event.pressed:
			return
		
		current_action_to_remap.update_keybinding(event)
		reset_remapping()
		
	elif event is InputEventMouseButton and event.pressed:
		accept_event()
		
		event = InputHelper.double_click_to_single(event)
		
		current_action_to_remap.update_keybinding(event)
		reset_remapping()
		accept_event()
		

func _ready() -> void:
	for child in NodeTraversal.find_nodes_of_custom_class(action_list, InputActionKeybindingDisplay):
		child.queue_free()
	
	set_process_input(is_remapping)
	load_input_keybindings(_get_input_map_actions())
		
	reset_to_default_button.pressed.connect(on_reset_to_default_pressed)


func load_input_keybindings(target_actions: Array[StringName]) -> void:
	for action: StringName in target_actions:
		var actions: Array[InputEvent] = InputMap.action_get_events(action)
			
		if actions.size() > 0:
			var input_action_keybinding: InputActionKeybindingDisplay = InputActionKeybindingScene.instantiate() as InputActionKeybindingDisplay
			action_list.add_child(input_action_keybinding)
			input_action_keybinding.setup(action, actions.front())
			input_action_keybinding.input_key_panel.gui_input.connect(on_input_keybinding_pressed.bind(input_action_keybinding))
	
	## Move the reset to default button to the end of the list
	action_list.move_child(reset_to_default_button, action_list.get_child_count() - 1)


func reset_remapping() -> void:
	is_remapping = false
	current_action_to_remap = null


func _get_input_map_actions() -> Array[StringName]:
	var input_map_actions: Array[StringName] = InputMap.get_actions() if include_ui_actions else InputMap.get_actions().filter(func(action): return !action.contains("ui_"))

	if exclude_actions.size() > 0:
		input_map_actions = input_map_actions.filter(func(action): return not action in exclude_actions)
		
	return input_map_actions
	

func on_reset_to_default_pressed() -> void:
	reset_remapping()
	
	var default_input_map_actions: Dictionary = GameSettings.DefaultSettings[GameSettings.DefaultInputMapActionsSetting]
	
	if not default_input_map_actions.is_empty():
		for input_action_keybinding: InputActionKeybindingDisplay in NodeTraversal.find_nodes_of_custom_class(action_list, InputActionKeybindingDisplay):
			var current_action: StringName = StringName(input_action_keybinding.action)
			
			if default_input_map_actions.has(current_action):
				input_action_keybinding.setup(current_action, default_input_map_actions[current_action].front())


func on_input_keybinding_pressed(event: InputEvent, input_action_keybinding: InputActionKeybindingDisplay) -> void:
	if InputHelper.is_mouse_left_click(event) and not is_remapping:
		is_remapping = true
		current_action_to_remap = input_action_keybinding
		current_action_to_remap.change_to_remapping_text()
		
