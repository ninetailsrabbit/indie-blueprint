@tool
class_name IndieBlueprintRotatorComponent2D extends Node2D

signal started
signal stopped
signal changed_rotation_direction(from: Vector2, to: Vector2)

## The Node2D type to apply the rotation
@export var target: Node2D:
	set(value):
		if target != value:
			target = value
			set_process(target != null and active)
@export var active: bool = false:
	set(value):
		if value != active:
			active = value
			
			if active:
				started.emit()
			else:
				stopped.emit()
			
			_update_turn_direction_timer()
			set_process(target != null and active)
			
## The initial direction the target will rotate
@export var rotation_direction: RotationDirection = RotationDirection.Clockwise:
	set(value):
		if rotation_direction != value:
			rotation_direction = value
			change_rotation_direction()
## Change the rotation direction after the seconds provided
@export var change_rotation_direction_after_seconds: int = 0:
	set(value):
		change_rotation_direction_after_seconds = maxi(0, absi(value))
		_update_turn_direction_timer()
			
## Reset the rotation speed when the rotation direction changes
@export var reset_rotation_speed_on_turn: bool = false
## The speed when it's rotating on clockwise
@export var clockwise_rotation_speed: float = 2.5
## The speed when it's rotating on counter-clockwise
@export var counter_clockwise_rotation_speed: float = 2.5
## The increase step amount that will be applied every frame to the main rotation speed
@export_range(0.0, 100.0, 0.01) var increase_step_rotation_speed: float = 0.0
## The maximum rotation speed this target can reach on clockwise
@export var max_clockwise_rotation_speed: float = 5.0
## The maximum rotation speed this target can reach on counter-clockwise
@export var max_counter_clockwise_rotation_speed: float = 5.0

enum RotationDirection {
	Clockwise,
	CounterClockwise
}

var original_rotation: float = 0.0
var current_rotation_speed: float = 0.0:
	set(value):
		current_rotation_speed = clampf(value, 0.0, max_clockwise_rotation_speed if _is_clockwise() else max_counter_clockwise_rotation_speed)

var current_rotation_direction: Vector2 = Vector2.RIGHT if _is_clockwise() else Vector2.LEFT
var turn_direction_timer: Timer


func _ready():
	if target == null:
		target = get_parent() as Node2D
	
	assert(target is Node2D, "IndieBlueprintRotatorComponent2D: This component needs a Node2D target to apply the rotation")
	
	original_rotation = rotation
	
	change_rotation_speed()
	_create_turn_direction_timer()
	set_process(active)
	
	if change_rotation_direction_after_seconds > 0:
		turn_direction_timer.start(change_rotation_direction_after_seconds)
	

func _process(delta: float):
	current_rotation_speed += increase_step_rotation_speed
	target.rotation += current_rotation_speed * current_rotation_direction.x * delta
	

func change_rotation_speed():
	current_rotation_speed = clockwise_rotation_speed if _is_clockwise() else counter_clockwise_rotation_speed
	
	
func stop():
	active = false


func start():
	active = true


func reset_to_original_rotation() -> void:
	rotation = original_rotation


func change_rotation_direction() -> void:
	var is_clockwise_direction = _is_clockwise()
	var from = Vector2.LEFT if is_clockwise_direction else Vector2.RIGHT
	var to = Vector2.RIGHT if is_clockwise_direction else Vector2.LEFT
	
	current_rotation_direction = to
	
	changed_rotation_direction.emit(from, to)
	
	if reset_rotation_speed_on_turn:
		change_rotation_speed()


func _update_turn_direction_timer() -> void:
	_create_turn_direction_timer()
	
	if active and change_rotation_direction_after_seconds > 0 and turn_direction_timer.is_stopped():
		turn_direction_timer.start(change_rotation_direction_after_seconds)
	else:
		turn_direction_timer.stop()


func _is_clockwise() -> bool:
	return rotation_direction == RotationDirection.Clockwise


func _is_counter_clockwise() -> bool:
	return rotation_direction == RotationDirection.CounterClockwise


func _create_turn_direction_timer():
	if turn_direction_timer == null:
		turn_direction_timer = IndieBlueprintTimeHelper.create_idle_timer(maxf(0.05, change_rotation_direction_after_seconds), false, true)
		turn_direction_timer.name = "TurnDirectionTimer"
	
	add_child(turn_direction_timer)
	turn_direction_timer.timeout.connect(on_turn_direction_timer_timeout)

	IndieBlueprintNodeTraversal.set_owner_to_edited_scene_root(turn_direction_timer)


func on_turn_direction_timer_timeout():
	rotation_direction = RotationDirection.CounterClockwise if _is_clockwise() else RotationDirection.Clockwise
