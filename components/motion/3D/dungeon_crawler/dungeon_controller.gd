@icon("res://components/motion/3D/dungeon_crawler/dungeon_controller.svg")
class_name IndieBlueprintDungeonController extends Node3D

@onready var camera: CameraShake3D = $CameraShake3D
@onready var dungeon_grid_movement: IndieBlueprintDungeonGridMovement3D = $DungeonGridMovement3D
@onready var front_raycast: RayCast3D = $FrontRaycast
@onready var back_raycast: RayCast3D = $BackRaycast
@onready var right_raycast: RayCast3D = $RightRaycast
@onready var left_raycast: RayCast3D = $LeftRaycast

@onready var raycast_detectors: Array[RayCast3D] = [front_raycast, back_raycast, right_raycast, left_raycast]

var motion_input: MotionInput = MotionInput.new(self)


func _ready() -> void:
	front_raycast.target_position = Vector3(0, 1.0, -dungeon_grid_movement.cell_travel_size - 0.1)
	back_raycast.target_position = Vector3(0, 1.0, dungeon_grid_movement.cell_travel_size + 0.1)
	right_raycast.target_position = Vector3(dungeon_grid_movement.cell_travel_size + 0.1, 1.0, 0)
	left_raycast.target_position = Vector3(-dungeon_grid_movement.cell_travel_size - 0.1, 1.0, 0)


func _physics_process(_delta: float) -> void:
	motion_input.update()
	
	if not motion_input.input_direction.is_zero_approx():
		handle_grid_movement(motion_input.input_direction)
		
	elif Input.is_action_just_pressed(InputControls.RotateLeft):
		handle_grid_movement(Vector2.LEFT, true)

	elif Input.is_action_just_pressed(InputControls.RotateRight):
		handle_grid_movement(Vector2.RIGHT, true)


func handle_grid_movement(direction: Vector2, rotation_movement: bool = false) -> void:
	if rotation_movement:
		dungeon_grid_movement.rotate(direction)
	else:
		if direction.is_equal_approx(Vector2.RIGHT) and right_raycast.is_colliding() \
			or direction.is_equal_approx(Vector2.LEFT) and left_raycast.is_colliding() \
			or direction.is_equal_approx(Vector2.UP) and front_raycast.is_colliding() \
			or direction.is_equal_approx(Vector2.DOWN) and back_raycast.is_colliding():
				return
		
		dungeon_grid_movement.move(direction)
