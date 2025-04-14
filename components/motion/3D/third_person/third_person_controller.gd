class_name IndieBlueprintThirdPersonController extends CharacterBody3D

@export var movement_mode: MovementMode = MovementMode.Free:
	set(new_mode):
		if movement_mode != new_mode:
			movement_mode = new_mode
			
			if is_node_ready():
				update_click_mode_state_machine()
				
		
@export var smooth_rotation: bool = true
@export var smooth_rotation_lerp_speed: float = 6.0
@export_category("Click movement")
@export var max_click_position_distance: float = 10.0
@export var can_change_click_position_while_moving: bool = true

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var camera: CameraShake3D = %Camera3D
@onready var click_mode_state_machine: IndieBlueprintFiniteStateMachine = $ClickModeStateMachine


enum MovementMode {
	Click,
	Free
}


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		IndieBlueprintCursorManager.switch_mouse_capture_mode()
		
		
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_click_mode_state_machine()
	
	click_mode_state_machine.register_transition(
		ThirdPersonClickModeNeutralStateToThirdPersonClickModeMovementStateTransition.new()
	)


func look_at_mouse() -> void:
	var mouse = get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mouse)
	var world_direction := camera.project_ray_normal(mouse)

	if world_direction.y != 0:
		var distance := -origin.y / world_direction.y
		var look_position := origin + world_direction * distance
		
		look_at(Vector3(look_position.x, global_position.y, look_position.z))


#region Click mode
func can_move_to_next_click_position(next_position: Vector3) -> bool:
	return global_position.distance_to(next_position) <= max_click_position_distance
	

func change_movement_mode(new_mode: MovementMode) -> void:
	movement_mode = new_mode
	

func movement_mode_is_free() -> bool:
	return movement_mode == MovementMode.Free


func movement_mode_is_click() -> bool:
	return movement_mode == MovementMode.Click
	
	
func update_click_mode_state_machine() -> void:
	if movement_mode_is_click():
		click_mode_state_machine.unlock_state_machine()
	else:
		click_mode_state_machine.lock_state_machine()
		
#endregion
