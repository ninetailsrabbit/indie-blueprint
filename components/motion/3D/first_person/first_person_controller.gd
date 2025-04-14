class_name IndieBlueprintFirstPersonController extends CharacterBody3D

@export_group("Mechanics")
@export var run: bool = true
@export var dash: bool = true
@export var air_dash: bool = true
@export var jump: bool = true
@export var crouch: bool = true
@export var crawl: bool = false
@export var slide: bool = true
@export var wall_run: bool = false
@export var wall_jump: bool = false
@export var wall_climb: bool = false
@export var surf: bool = false
@export var swim: bool = false
@export var stairs: bool = true
@export var ladder_climb: bool = false

@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var body_collision_shape: CollisionShape3D = $BodyCollisionShape
@onready var ceil_shape_cast: ShapeCast3D = $Head/CeilShapeCast
@onready var fire_arm_weapon_manager: FireArmWeaponManager = $FireArmWeaponManager

@onready var camera_controller: IndieBlueprintFirstPersonCameraController = $Head/IndieBlueprintFirstPersonCameraController
@onready var camera: CameraShake3D = $Head/Eyes/CameraShake3D
@onready var footsteps_manager: FootstepsManager3D = $FootstepsManager3D
@onready var state_machine: IndieBlueprintFiniteStateMachine = $MotionStateMachine

var motion_input: MotionInput = MotionInput.new(self)
var was_grounded: bool = false
var is_grounded: bool = false
var original_head_position: Vector3


func _unhandled_key_input(_event: InputEvent) -> void:
	if IndieBlueprintInputHelper.is_any_action_just_pressed([InputControls.PauseGame, &"ui_cancel"]):
		IndieBlueprintCursorManager.switch_mouse_capture_mode()
		
## Only active when gamepad is connected
func _unhandled_input(_event: InputEvent) -> void:
	if IndieBlueprintInputHelper.is_any_action_just_pressed([InputControls.PauseGame, &"ui_cancel"]):
		IndieBlueprintCursorManager.switch_mouse_capture_mode()
		

func _ready() -> void:
	IndieBlueprintInputHelper.capture_mouse()

	collision_layer = IndieBlueprintGameGlobals.player_collision_layer
	original_head_position = head.position
	
	state_machine.register_transitions([
		FirstPersonWalkStateToFirstPersonRunStateTransition.new(),
		FirstPersonRunStateToFirstPersonWalkTransition.new()
	])
	
	state_machine.state_changed.connect(on_state_changed)
	
	update_gamepad_support()
	IndieBlueprintGamepadControllerManager.controller_connected.connect(on_gamepad_connected)
	IndieBlueprintGamepadControllerManager.controller_disconnected.connect(on_gamepad_disconnected)


func _physics_process(_delta: float) -> void:
	motion_input.update()
	was_grounded = is_grounded
	is_grounded = is_on_floor()
	

func is_falling() -> bool:
	var opposite_up_direction = IndieBlueprintVectorHelper.up_direction_opposite_vector3(up_direction)
	
	var opposite_to_gravity_vector: bool = (opposite_up_direction.is_equal_approx(Vector3.DOWN) and velocity.y < 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.UP) and velocity.y > 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.LEFT) and velocity.x < 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.RIGHT) and velocity.x > 0)
	
	return not is_grounded and opposite_to_gravity_vector


func is_aiming() -> bool:
	return (fire_arm_weapon_manager.left_hand.weapon_equipped \
		and fire_arm_weapon_manager.left_hand.weapon_equipped.is_aiming()) \
		or (fire_arm_weapon_manager.right_hand.weapon_equipped \
		and fire_arm_weapon_manager.right_hand.weapon_equipped.is_aiming())


#region Locks
func lock() -> void:
	lock_movement()
	lock_camera()
	
	
func unlock() -> void:
	unlock_movement()
	unlock_camera()


func lock_movement() -> void:
	state_machine.lock_state_machine()

	
func unlock_movement() -> void:
	state_machine.unlock_state_machine()


func lock_camera() -> void:
	camera_controller.lock()

	
func unlock_camera() -> void:
	camera_controller.unlock()
#endregion


func update_gamepad_support() -> void:
	set_process_unhandled_key_input(IndieBlueprintGamepadControllerManager.current_controller_is_keyboard())
	set_process_unhandled_input(not IndieBlueprintGamepadControllerManager.current_controller_is_keyboard())


func on_state_changed(_from:IndieBlueprintMachineState, to: IndieBlueprintMachineState) -> void:
	match to.name:
		"FirstPersonCrouchState":
			body_collision_shape.shape.height = 1.3
			body_collision_shape.shape.radius = 0.5
			body_collision_shape.position.y = body_collision_shape.shape.height / 2.0
			
		"FirstPersonCrawlState":
			body_collision_shape.shape.height = 0.9
			body_collision_shape.shape.radius = 0.35
			body_collision_shape.position.y = body_collision_shape.shape.height / 2.0
		_:
			body_collision_shape.shape.height = 2.0
			body_collision_shape.shape.radius = 0.5
			body_collision_shape.position.y = body_collision_shape.shape.height / 2.0


func on_gamepad_connected(_device_id, _controller_name: String) -> void:
	update_gamepad_support()

	
func on_gamepad_disconnected(_device_id, _previous_controller_name: String, _controller_name: String) -> void:
	update_gamepad_support()
