extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera_shake_3d: Camera3D = $Head/CameraShake3D


var mouse_input: Vector2 = Vector2.ZERO
var look_sensitivity = 0.005


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		CursorManager.switch_mouse_capture_mode()
	
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event.xformed_by(get_tree().root.get_final_transform())
		mouse_input = motion.relative


func _ready() -> void:
	CursorManager.capture_mouse()


func _physics_process(delta: float) -> void:
	rotate_y(-mouse_input.x * look_sensitivity)
	camera_shake_3d.rotate_x(-mouse_input.y * look_sensitivity)
	camera_shake_3d.rotation.x = clamp(camera_shake_3d.rotation.x, -1.5, 1.5)
	
	mouse_input = Vector2.ZERO
	

func switch_mouse_capture_mode() -> void:
	if InputHelper.is_mouse_visible():
		InputHelper.capture_mouse()
	else:
		InputHelper.show_mouse_cursor()
