class_name IndieBlueprintSpringArmPivot extends Node3D

@export var actor: IndieBlueprintThirdPersonController
@export var mouse_sensitivity: float = 0.5
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = -PI / 2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = PI / 4
@export var max_zoom_out: float = 6.0
@export var max_zoom_in: float = 1.0
@export var zoom_out_step: float = 0.5
@export var zoom_in_step: float = 0.5
@export var camera_smoothness: float = 6.0
## When an action is set, this needs to be pressed in order to manually move the camera
@export var press_action_to_manual_camera: StringName

@onready var spring_arm_3d: SpringArm3D = $SpringArm3D
@onready var spring_position: Node3D = $SpringArm3D/SpringPosition
@onready var camera: Camera3D = $Camera3D

var spring_arm_pivot_height: float = 0.0
var camera_manual_motion: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if press_action_to_manual_camera and IndieBlueprintInputHelper.action_pressed_and_exists(press_action_to_manual_camera):
		camera_manual_motion = true
	elif press_action_to_manual_camera.is_empty() and IndieBlueprintInputHelper.is_mouse_captured():
		camera_manual_motion = true
	else:
		camera_manual_motion = false
	
	if event is InputEventMouseMotion and camera_manual_motion:
		rotate_camera(event.relative)
	
	if IndieBlueprintInputHelper.action_pressed_and_exists(InputControls.ZoomInCamera):
		camera_zoom_in()
		
	elif IndieBlueprintInputHelper.action_pressed_and_exists(InputControls.ZoomOutCamera):
		camera_zoom_out()


func rotate_camera(relative_position: Vector2) -> void:
	var mouse_sens: float = mouse_sensitivity / 1000 # radians/pixel, 3 becomes 0.003
	
	rotation.y -= relative_position.x * mouse_sens
	rotation.y = wrapf(rotation.y, 0.0, TAU)
	
	rotation.x -= relative_position.y * mouse_sens
	rotation.x =  clampf(rotation.x, min_vertical_angle, max_vertical_angle)


func camera_zoom_in() -> void:
	spring_arm_3d.spring_length -= zoom_in_step
	spring_arm_3d.spring_length = maxf(max_zoom_in, spring_arm_3d.spring_length)

		
func camera_zoom_out() -> void:
		spring_arm_3d.spring_length += 1
		spring_arm_3d.spring_length = min(max_zoom_out, spring_arm_3d.spring_length)
		
	
func _ready() -> void:
	## To ignore the parent transform so the camera does not rotate when the player does
	top_level = true
	
	spring_arm_pivot_height = position.y
	mouse_sensitivity = IndieBlueprintSettingsManager.get_accessibility_section(IndieBlueprintGameSettings.MouseSensivitySetting)
	camera_manual_motion = press_action_to_manual_camera.is_empty()
	

func _physics_process(delta: float) -> void:
	 ## When top-level is enabled, we need to update the global position to keep the normal behaviour
	if top_level:
		global_position = actor.global_position
		position.y = spring_arm_pivot_height
		
	camera.position = lerp(camera.position, spring_position.position, delta * camera_smoothness)
