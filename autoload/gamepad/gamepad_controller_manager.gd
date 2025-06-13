# Nintendo switch pro controllers does not work yet https://github.com/godotengine/godot/issues/81191
extends Node

signal controller_connected(device_id, controller_name: String)
signal controller_disconnected(device_id, previous_controller_name: String, controller_name: String)

const default_vibration_strength = 0.5
const default_vibration_duration = 0.65

const DeviceGeneric: StringName = &"generic"
const DeviceKeyboard: StringName = &"keyboard"
const DeviceXboxController: StringName = &"xbox"
const DeviceSwitchController: StringName = &"switch"
const DeviceSwitchJoyconLeftController: StringName = &"switch_left_joycon"
const DeviceSwitchJoyconRightController: StringName = &"switch_right_joycon"
const DevicePlaystationController: StringName = &"playstation"
const DeviceLunaController: StringName = &"luna"

const XboxButtonLabels = ["A", "B", "X", "Y", "Back", "Home", "Menu", "Left Stick", "Right Stick", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right", "Share"]
const SwitchButtonLabels = ["B", "A", "Y", "X", "-", "", "+", "Left Stick", "Right Stick", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right", "Capture"]
const PlaystationButtonLabels = ["Cross", "Circle", "Square", "Triangle", "Select", "PS", "Options", "L3", "R3", "L1", "R1", "Up", "Down", "Left", "Right", "Microphone"]


var current_controller_guid
var current_controller_device := DeviceKeyboard
var current_controller_name: String = "Keyboard"
var current_device_id := 0
var connected: bool = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Input.stop_joy_vibration(current_device_id)


func _enter_tree() -> void:
	Input.joy_connection_changed.connect(on_joy_connection_changed)
	

func _ready() -> void:
	for joypad in joypads():
		print_rich("Found joypad #%d: [b]%s[/b] - %s" % [joypad, Input.get_joy_name(joypad), Input.get_joy_guid(joypad)])


func has_joypad() -> bool:
	return joypads().size() > 0

## Array of device ids
func joypads() -> Array[int]:
	return Input.get_connected_joypads()


func start_controller_vibration(weak_strength = default_vibration_strength, strong_strength = default_vibration_strength, duration = default_vibration_duration):
	if not current_controller_is_keyboard() and has_joypad():
		Input.start_joy_vibration(current_device_id, weak_strength, strong_strength, duration)


func stop_controller_vibration():
	if not current_controller_is_keyboard() and has_joypad():
		Input.stop_joy_vibration(current_device_id)


func update_current_controller(device: int, controller_name: String) -> void:
	##https://github.com/mdqinc/SDL_GameControllerDB
	current_controller_guid = Input.get_joy_guid(device)
	current_device_id = device
	current_controller_name = controller_name
	
	match controller_name:
		"Luna Controller":
			current_controller_device = DeviceLunaController
		"XInput Gamepad", "Xbox One For Windows", "Xbox Series Controller", "Xbox 360 Controller", \
		"Xbox One Controller": 
			current_controller_device = DeviceXboxController
		"Sony DualSense","Nacon Revolution Unlimited Pro Controller",\
		"PS3 Controller", "PS4 Controller", "PS5 Controller":
			current_controller_device = DevicePlaystationController
		"Steam Virtual Gamepad": 
			current_controller_device = DeviceGeneric
		"Switch","Switch Controller","Nintendo Switch Pro Controller",\
		"Faceoff Deluxe Wired Pro Controller for Nintendo Switch":
			current_controller_device = DeviceSwitchController
		"Joy-Con (L)":
			current_controller_device = DeviceSwitchJoyconLeftController
		"Joy-Con (R)":
			current_controller_device = DeviceSwitchJoyconRightController
		_: 
			current_controller_device = DeviceKeyboard
			current_controller_name = "Keyboard"


#region Controller detectors
func current_controller_is_generic() -> bool:
	return current_controller_device == DeviceGeneric


func current_controller_is_luna() -> bool:
	return current_controller_device == DeviceLunaController


func current_controller_is_keyboard() -> bool:
	return current_controller_device == DeviceKeyboard


func current_controller_is_playstation() -> bool:
	return current_controller_device == DevicePlaystationController


func current_controller_is_xbox() -> bool:
	return current_controller_device == DeviceXboxController


func current_controller_is_switch() -> bool:
	return current_controller_device == DeviceSwitchController


func current_controller_is_switch_joycon() -> bool:
	return current_controller_device in [DeviceSwitchJoyconLeftController, DeviceSwitchJoyconRightController]


func current_controller_is_switch_joycon_right() -> bool:
	return current_controller_device == DeviceSwitchJoyconRightController


func current_controller_is_switch_joycon_left() -> bool:
	return current_controller_device == DeviceSwitchJoyconLeftController
#endregion


func on_joy_connection_changed(device_id: int, joy_connected: bool):
	var previous_controller_name: String = current_controller_name
	update_current_controller(device_id, Input.get_joy_name(device_id) if joy_connected else "")
	
	if joy_connected:
		controller_connected.emit(device_id, current_controller_name)
		print_rich("[color=green]Found newly connected joypad #%d: [b]%s[/b] - %s[/color]" % [device_id, Input.get_joy_name(device_id), Input.get_joy_guid(device_id)])
	else:
		controller_disconnected.emit(device_id, previous_controller_name, current_controller_name)
		print_rich("[color=red]Disconnected joypad [b]%s[/b] with id #%d[/color]" % [previous_controller_name, device_id])
