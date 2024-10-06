class_name InputHelper extends Node

static var numeric_keys = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105]

static func is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed


static func is_mouse_right_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed


static func is_mouse_left_button_pressed(event: InputEvent) -> bool:
	return  event is InputEventMouse and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


static func is_mouse_right_button_pressed(event: InputEvent) -> bool:
	return event is InputEventMouse and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)


static func is_mouse_visible() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_VISIBLE || Input.mouse_mode == Input.MOUSE_MODE_CONFINED


static func is_mouse_captured() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED


static func show_mouse_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


static func show_mouse_cursor_confined() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


static func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


static func hide_mouse_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


static func hide_mouse_cursor_confined() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


static func is_controller_button(event: InputEvent) -> bool:
	return event is InputEventJoypadButton
	
	
static func is_controller_axis(event: InputEvent) -> bool:
	return event is InputEventJoypadMotion
	
	
static func is_gamepad_input(event: InputEvent) -> bool:
	return is_controller_button(event) or is_controller_axis(event)


static func numeric_key_pressed(event: InputEvent) -> bool:
	return event is InputEventKey and event.pressed && (numeric_keys.has(int(event.keycode)) || numeric_keys.has(int(event.physical_keycode)) )


static func readable_key(key: InputEventKey):
	var key_with_modifiers: Key = key.get_physical_keycode_with_modifiers() if key.keycode == KEY_NONE else key.get_keycode_with_modifiers()
	
	return OS.get_keycode_string(key_with_modifiers).replace("+", "+ ")


static func action_just_pressed_and_exists(action: String) -> bool:
	return InputMap.has_action(action) and Input.is_action_just_pressed(action)


static func action_pressed_and_exists(action: String, event: InputEvent = null) -> bool:
	return InputMap.has_action(action) and event.is_action_pressed(action) if event else Input.is_action_pressed(action)


static func action_just_released_and_exists(action: String) -> bool:
	return InputMap.has_action(action) and Input.is_action_just_released(action)


static func action_released_and_exists(event: InputEvent, action: String) -> bool:
	return InputMap.has_action(action) and event.is_action_released(action)


static func is_any_action_just_pressed(_event:InputEvent, actions: Array = []):
	for action in actions:
		if Input.is_action_just_pressed(action):
			return true
			
	return false
	

static func is_any_action_pressed(event: InputEvent, actions: Array = []):
	for action in actions:
		if event.is_action_pressed(action):
			return true
			
	return false


static func is_any_action_released(event:InputEvent, actions: Array = []):
	for action in actions:
		if event.is_action_released(action):
			return true
			
	return false


static func release_input_actions(actions: Array[StringName] = []):
	for action in InputMap.get_actions().filter(func(input_action: StringName): return input_action in actions):
		Input.action_release(action)
		

static func get_all_inputs_for_action(action: String) -> Array[InputEvent]:
	return InputMap.action_get_events(action)
	
	
static func get_keyboard_inputs_for_action(action: String) -> Array[InputEvent]:
	return InputMap.action_get_events(action).filter(func(event):
		return event is InputEventKey or event is InputEventMouseButton
	)

## Output example: InputEventKey: keycode=4194309 (Enter), mods=none, physical=false, pressed=false, echo=false
static func get_keyboard_input_for_action(action: String) -> InputEvent:
	var inputs: Array[InputEvent] = InputHelper.get_keyboard_inputs_for_action(action)
	
	return null if inputs.is_empty() else inputs[0]


static func get_joypad_inputs_for_action(action: String) -> Array[InputEvent]:
	return InputMap.action_get_events(action).filter(func(event):
		return event is InputEventJoypadButton or event is InputEventJoypadMotion
	)

static func get_joypad_input_for_action(action: String) -> InputEvent:
	var buttons: Array[InputEvent] = get_joypad_inputs_for_action(action)
	return null if buttons.is_empty() else buttons[0]
