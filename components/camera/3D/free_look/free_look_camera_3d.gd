@icon("res://components/camera/3D/free_look/free_look_camera.svg")
class_name FreeLookCamera3D extends Camera3D

signal free_camera_enabled
signal free_camera_disabled

@export var mouse_mode_switch_input_actions: Array[String] = ["ui_cancel"]
@export_range(0.01, 20.0, 0.01) var mouse_sensitivity: float = 3.0
@export var speed: float = 0.2:
	set(value):
		speed = clamp(value, min_speed, max_speed)
@export var min_speed: float = 0.2
@export var max_speed: float = 5.0
@export var speed_increase_per_step: float = 0.1
@export var toggle_activation_key := KEY_TAB
@export var move_forward_key := KEY_W
@export var move_back_key := KEY_S
@export var move_left_key := KEY_A
@export var move_right_key := KEY_D
@export var increment_speed_key := MOUSE_BUTTON_WHEEL_UP
@export var decrement_speed_key := MOUSE_BUTTON_WHEEL_DOWN

var previous_camera: Camera3D

var active: bool = false:
	set(value):
		if value != active and is_node_ready():
			if value:
				free_camera_enabled.emit()
			else:
				free_camera_disabled.emit()
				
			active = value
		
var motion: Vector3
var view_motion: Vector2
var gimbal_base : Transform3D
var gimbal_pitch : Transform3D
var gimbal_yaw : Transform3D
var previous_mouse_mode: Input.MouseMode


func _ready():
	gimbal_base.origin = global_transform.origin
	current = active
	set_as_top_level(true)
	
	mouse_sensitivity = SettingsManager.get_accessibility_section(GameSettings.MouseSensivitySetting)
	
	free_camera_enabled.connect(on_free_camera_enabled)
	free_camera_disabled.connect(on_free_camera_disabled)
	SettingsManager.updated_setting_section.connect(on_mouse_sensitivity_changed)
	
	previous_mouse_mode = Input.mouse_mode


func _input(event):
	if active:
		if InputHelper.is_any_action_just_pressed(mouse_mode_switch_input_actions):
			switch_mouse_capture_mode()
			
		if event is InputEventMouseMotion:
			view_motion += event.xformed_by(get_tree().root.get_final_transform()).relative
			
		if event is InputEventMouseButton:
			if event.button_index == increment_speed_key:
				speed += speed_increase_per_step
			if event.button_index == decrement_speed_key:
				speed -= speed_increase_per_step
			

	if event is InputEventKey:
		if event.keycode == toggle_activation_key and event.pressed:
			active = not active
			
			if not active:
				return
		
		var motion_value := int(event.pressed) # translate bool into 1 or 0
		
		match event.keycode:
			move_forward_key:
				motion.z = -motion_value
			move_back_key:
				motion.z = motion_value
			move_right_key:
				motion.x = motion_value
			move_left_key:
				motion.x = -motion_value


func _process(_delta):
	gimbal_base *= Transform3D(Basis(), global_transform.basis * (motion * speed))

	gimbal_yaw = gimbal_yaw.rotated(Vector3.UP, view_motion.x * (mouse_sensitivity / 1000) * -1.0)
	gimbal_pitch = gimbal_pitch.rotated(Vector3.RIGHT, view_motion.y * (mouse_sensitivity / 1000) * -1.0)
	view_motion = Vector2()

	global_transform = gimbal_base * (gimbal_yaw * gimbal_pitch)


func enable() -> void:
	active = true
	

func disable() -> void:
	active = false
	
	
func is_active() -> bool:
	return active
	
	
func switch_mouse_capture_mode() -> void:
	if InputHelper.is_mouse_visible():
		InputHelper.capture_mouse()
	else:
		InputHelper.show_mouse_cursor()


func on_free_camera_enabled():
	previous_camera = get_viewport().get_camera_3d()
	
	make_current()
	set_process(true)
	set_process_input(true)
	
	Input.mouse_mode = previous_mouse_mode
	InputHelper.capture_mouse()
	
	
func on_free_camera_disabled():
	gimbal_base.origin = global_transform.origin
	
	if previous_camera:
		clear_current()
		previous_camera.make_current()
		print("comeback to ", previous_camera)
	
	set_process(false)
	
	Input.mouse_mode = previous_mouse_mode


func on_mouse_sensitivity_changed(section: String, key: String, value: Variant) -> void:
	if section == GameSettings.AccessibilitySection and key == GameSettings.MouseSensivitySetting:
		mouse_sensitivity = value