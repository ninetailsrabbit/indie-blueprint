@icon("res://components/rotation/2D/rotator_component_2d.svg")
class_name RotatorComponent2D extends Node2D

signal started
signal stopped
signal changed_rotation_direction(from: Vector2, to: Vector2)

## The Node2D type to apply the rotation
@export var target: Node2D
## The initial direction the target will rotate
@export var initial_direction: RotationDirection = RotationDirection.Clockwise
## Change the rotation direction after the seconds provided
@export var change_rotation_direction_after_seconds: int = 0:
	set(value):
		change_rotation_direction_after_seconds = max(0, abs(value))
		
		if is_node_ready() and change_rotation_direction_after_seconds > 0:
			_create_turn_direction_timer()
			if turn_direction_timer.is_stopped():
				turn_direction_timer.start()
		else:
			if is_instance_valid(turn_direction_timer):
				turn_direction_timer.stop()

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

var current_rotation_speed := 0.0:
	set(value):
		current_rotation_speed = clamp(value, 0, max_clockwise_rotation_speed if _is_clockwise() else max_counter_clockwise_rotation_speed)

var current_rotation_direction := Vector2.RIGHT
var turn_direction_timer: Timer

var active := false:
	set(value):
		if value != active:
			if value:
				started.emit()
				set_process(true)
			else:
				stopped.emit()
				set_process(false)
				
		active = value


func _ready():
	if target == null:
		target = get_parent() as Node2D
	
	assert(target is Node2D, "RotatorComponent2D: This component needs a Node2D target to apply the rotation")
	
	change_rotation_speed()
	
	if initial_direction == RotationDirection.CounterClockwise:
		current_rotation_direction = Vector2.LEFT
	
	if change_rotation_direction_after_seconds:
		_create_turn_direction_timer()


func _process(delta):
	current_rotation_speed += increase_step_rotation_speed
	target.rotation += current_rotation_speed * current_rotation_direction.x * delta

		
func change_rotation_speed():
	current_rotation_speed = clockwise_rotation_speed if _is_clockwise() else counter_clockwise_rotation_speed
	
	
func stop():
	active = false


func start():
	active = true


func _create_turn_direction_timer():
	if turn_direction_timer == null:
		turn_direction_timer = Timer.new()
		turn_direction_timer.name = "TurnDirectionTimer"
		turn_direction_timer.process_callback = Timer.TIMER_PROCESS_IDLE
		turn_direction_timer.wait_time = change_rotation_direction_after_seconds
		turn_direction_timer.autostart = true
		turn_direction_timer.one_shot = false
		
		add_child(turn_direction_timer)
		turn_direction_timer.timeout.connect(on_turn_direction_timer_timeout)


func _is_clockwise() -> bool:
	return sign(current_rotation_direction.x) > 0


func on_turn_direction_timer_timeout():
	var is_clockwise_direction = _is_clockwise()
	var from = Vector2.RIGHT if is_clockwise_direction else Vector2.LEFT
	var to = Vector2.LEFT if is_clockwise_direction else Vector2.RIGHT
	
	changed_rotation_direction.emit(from, to)
	current_rotation_direction *= sign(to.x)
	
	if reset_rotation_speed_on_turn:
		change_rotation_speed()
	
	
