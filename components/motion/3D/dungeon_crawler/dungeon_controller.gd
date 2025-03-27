@icon("res://components/motion/3D/dungeon_crawler/dungeon_controller.svg")
class_name IndieBlueprintDungeonController extends Node3D

@onready var camera: CameraShake3D = $CameraShake3D
@onready var dungeon_grid_movement: IndieBlueprintDungeonGridMovement3D = $DungeonGridMovement3D


var motion_input: MotionInput = MotionInput.new(self)

	
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
		dungeon_grid_movement.move(direction)
