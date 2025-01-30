@icon("res://components/motion/3D/first-person/controller/first_person_controller.svg")
class_name FirstPersonController extends CharacterBody3D

const GroupName: StringName = &"player"

@export var mouse_mode_switch_input_actions: Array[String] = ["ui_cancel"]
@export_group("Camera FOV")
@export var dinamic_camera_fov: bool = true
@export var fov_lerp_factor: float = 5.0
@export var fov_by_state: Dictionary
@export_group("Mechanics")
@export var run: bool = true
@export var jump: bool = true
@export var crouch: bool = true
@export var crawl: bool = false
@export var slide: bool = true
@export var wall_run: bool = false:
	set(value):
		if value != wall_run:
			wall_run = value
			_update_wall_checkers()
@export var wall_jump: bool = false:
	set(value):
		if value != wall_jump:
			wall_jump = value
			_update_wall_checkers()
@export var wall_climb: bool = false
@export var surf: bool = false
@export var swim: bool = false
@export var stairs: bool = true:
	set(value):
		if value != stairs:
			stairs = value
			_update_wall_checkers()
@export var ladder_climb: bool = false
@onready var debug_ui: CanvasLayer = $DebugUI
@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var camera: CameraShake3D = $CameraController/Head/CameraShake3D
@onready var camera_controller: CameraController3D = $CameraController

@onready var submerged_effect: ColorRect = $PostProcessingEffects/Submerged

## This raycast detects walls so the stair up and stair down is not applied to avoid a weird
## stuttering movement on irregular vertical surfaces
@onready var front_close_wall_checker: RayCast3D = %FrontCloseWallChecker
@onready var back_close_wall_checker: RayCast3D = %BackCloseWallChecker
@onready var right_wall_checker: RayCast3D = %RightWallChecker
@onready var right_wall_checker_2: RayCast3D = %RightWallChecker2
@onready var left_wall_checker: RayCast3D = %LeftWallChecker
@onready var left_wall_checker_2: RayCast3D = %LeftWallChecker2

@onready var ceil_shape_cast: ShapeCast3D = $CeilShapeCast
@onready var ladder_cast_detector: ShapeCast3D = $LadderCastDetector

@onready var footsteps_manager_3d: FootstepsManager3D = $FootstepsManager3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stand_collision_shape: CollisionShape3D = $StandCollisionShape
@onready var crouch_collision_shape: CollisionShape3D = $CrouchCollisionShape
@onready var crawl_collision_shape: CollisionShape3D = $CrawlCollisionShape

@onready var original_camera_fov = camera.fov
@onready var fire_arm_weapon_holder: FireArmWeaponHolder = $CameraController/Head/CameraShake3D/FireArmWeaponHolder


var was_grounded: bool = false
var is_grounded: bool = false
var is_underwater: bool = false:
	set(value):
		if value != is_underwater:
			is_underwater = value
			submerged_effect.visible = is_underwater
			
var motion_input: TransformedInput
var last_direction: Vector3 = Vector3.ZERO


func _unhandled_key_input(_event: InputEvent) -> void:
	if InputHelper.is_any_action_just_pressed(mouse_mode_switch_input_actions):
		switch_mouse_capture_mode()


func _enter_tree() -> void:
	add_to_group(GroupName)
	
	
func _ready() -> void:
	_update_wall_checkers()
	
	collision_layer = GameGlobals.player_collision_layer
	debug_ui.visible = OS.is_debug_build()
	submerged_effect.visible = is_underwater

	motion_input = TransformedInput.new(self)
	InputHelper.capture_mouse()
	
	finite_state_machine.register_transitions([
		WalkToRunTransition.new(),
		RunToWalkTransition.new(),
		AnyToWallRunTransition.new(),
		WallRunToFallTransition.new(),
		WallRunToWallJumpTransition.new(),
		AnyToLadderClimbTransition.new()
	])
	
	finite_state_machine.state_changed.connect(on_state_changed)
	

func _physics_process(delta: float) -> void:
	motion_input.update()
	
	was_grounded = is_grounded
	is_grounded = is_on_floor()
	
	_update_camera_fov(finite_state_machine.current_state, delta)


func is_aiming() -> bool:
	return fire_arm_weapon_holder.firearm_weapon_placement.current_aim_state == FireArmWeapon.AimStates.Aim
	
	
func is_falling() -> bool:
	var opposite_up_direction = VectorHelper.up_direction_opposite_vector3(up_direction)
	
	var opposite_to_gravity_vector: bool = (opposite_up_direction.is_equal_approx(Vector3.DOWN) and velocity.y < 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.UP) and velocity.y > 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.LEFT) and velocity.x < 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.RIGHT) and velocity.x > 0)
	
	return not is_grounded and opposite_to_gravity_vector


func wall_detected() -> bool:
	var right_wall: bool = right_wall_checker.is_colliding() or right_wall_checker_2.is_colliding()
	var left_wall: bool = left_wall_checker.is_colliding() or left_wall_checker_2.is_colliding()

	return wall_jump and (right_wall or left_wall)
	

func get_current_wall_detected_normal() -> Vector3:
	if right_wall_checker.is_colliding():
		return right_wall_checker.get_collision_normal()
	elif right_wall_checker_2.is_colliding():
		return right_wall_checker_2.get_collision_normal()
	elif left_wall_checker.is_colliding():
		return left_wall_checker.get_collision_normal()
	elif left_wall_checker_2.is_colliding():
		return left_wall_checker_2.get_collision_normal()
	else:
		return Vector3.ZERO


func get_current_wall_side() -> Vector3:
	var right_wall: bool = right_wall_checker.is_colliding() or right_wall_checker_2.is_colliding()
	var left_wall: bool = left_wall_checker.is_colliding() or left_wall_checker_2.is_colliding()
	
	if right_wall:
		return Vector3.RIGHT
	elif left_wall:
		return Vector3.LEFT
	else:
		return Vector3.ZERO


func lock_movement() -> void:
	finite_state_machine.lock_state_machine()

	
func unlock_movement() -> void:
	finite_state_machine.unlock_state_machine()


func lock_camera() -> void:
	camera_controller.lock()

	
func unlock_camera() -> void:
	camera_controller.unlock()


func switch_mouse_capture_mode() -> void:
	if InputHelper.is_mouse_visible():
		InputHelper.capture_mouse()
	else:
		InputHelper.show_mouse_cursor()


func _update_wall_checkers() -> void:
	if is_inside_tree():
		right_wall_checker.enabled = wall_jump or wall_run
		right_wall_checker_2.enabled = wall_jump or wall_run
		left_wall_checker.enabled = wall_jump or wall_run
		left_wall_checker_2.enabled = wall_jump or wall_run
		
		front_close_wall_checker.enabled = stairs
		back_close_wall_checker.enabled = stairs


func _update_collisions_based_on_state(current_state: MachineState) -> void:
	match current_state.name:
		"Idle", "Walk", "Run":
			stand_collision_shape.disabled = false
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = true
		"Crouch", "Slide":
			stand_collision_shape.disabled = true
			crouch_collision_shape.disabled = false
			crawl_collision_shape.disabled = true
		"Crawl":
			stand_collision_shape.disabled = true
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = false
		_:
			stand_collision_shape.disabled = false
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = true

#
func _update_camera_fov(current_state: MachineState, delta: float = get_physics_process_delta_time()) -> void:
	if not dinamic_camera_fov or fov_by_state.is_empty():
		return
		
	var state_name: String = current_state.name.to_lower()
	
	if fov_by_state.has(state_name):
		camera.fov = lerpf(camera.fov, fov_by_state[state_name], fov_lerp_factor * delta)
	else:
		camera.fov = lerpf(camera.fov, original_camera_fov, fov_lerp_factor * delta)


func on_state_changed(_from: MachineState, to: MachineState) -> void:
	_update_collisions_based_on_state(to)


#func on_interactable_interacted(interactable: Interactable3D) -> void:
	#if interactable.lock_player_on_interact:
		#lock_movement()
	#

#func on_interactable_canceled_interaction(_interactable: Interactable3D) -> void:
	#unlock_movement()
	#camera.make_current()
	#InputHelper.capture_mouse()
