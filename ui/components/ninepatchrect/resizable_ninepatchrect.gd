@icon("res://ui/components/ninepatchrect/resizable_ninepatchrect.svg")
class_name ResizableNinePatchRect extends NinePatchRect


class ResizeTransition extends RefCounted:
	var new_dimension: Vector2
	var duration: float
	
	func _init(_new_dimension: Vector2, _duration: float):
		new_dimension = _new_dimension
		duration = _duration


class RotationTransition extends RefCounted:
	var angle: float
	var duration: float
	
	func _init(_angle: float, _duration: float):
		angle = _angle
		duration = _duration


signal resize_requested(from: Vector2, to: Vector2)
signal resize_finished(from: Vector2, to: Vector2)
signal rotation_requested(from_angle: float, to_angle: float)
signal rotation_finished(from_angle: float, to_angle: float)

## The initial size to display
@export var initial_rect_size: Vector2 = Vector2(700, 200)
## The initial angle this rect will be
@export var initial_angle: float = 0.0
## When enabled, collision on borders are active
@export var use_border_collisions: bool = true:
	set(value):
		if value != use_border_collisions:
			use_border_collisions = value
			
			adapt_collisions()
## The collision border size
@export var collision_border_size: int = 5
## The animation duration in seconds to resize this rect
@export var default_resize_transition_duration: float = 1.5
## The animation duration in seconds to rotate this rect
@export var default_rotation_transition_duration: float = 1.5
## If this is enabled, when a resize is requested while another transition is running, will be appended to the queue and executed later
@export var queue_resize_transitions: bool = true
## If this is enabled, when a resize is requested while another transition is running, will be appended to the queue and executed later
@export var queue_rotation_transitions: bool = true
## The delay in seconds between transitions when they are queued
@export var delay_between_transitions: float = 0.1

@onready var top_collision: CollisionShape2D = $BoxCollisions/TopCollision
@onready var bottom_collision: CollisionShape2D = $BoxCollisions/BottomCollision
@onready var right_collision: CollisionShape2D = $BoxCollisions/RightCollision
@onready var left_collision: CollisionShape2D = $BoxCollisions/LeftCollision

var resize_tween: Tween
var rotation_tween: Tween
var general_queue: Array[Variant] = []


func _ready():
	set_physics_process(false)
	
	mouse_filter = MOUSE_FILTER_IGNORE
	
	size = initial_rect_size
	rotation = initial_angle
	
	adjust_to_viewport_center()
	adapt_collisions()
	
	resize_finished.connect(on_resize_finished)
	rotation_finished.connect(on_rotation_finished)
	

func _physics_process(_delta: float) -> void:
	adapt_collisions()
	

func center() -> Vector2:
	return global_position + get_rect().size / 2.0
	

func adjust_to_viewport_center() -> void:
	position = Vector2(( (get_viewport_rect().size.x / 2.0) - size.x / 2.0), get_viewport_rect().size.y / 2.0 )
	
	
func adapt_collisions() -> void:
	if is_inside_tree():
		if use_border_collisions:
			top_collision.position = Vector2(size.x / 2, 0)
			top_collision.shape.size = Vector2(size.x, collision_border_size)
			
			bottom_collision.position = Vector2(size.x / 2, size.y)
			bottom_collision.shape.size = Vector2(size.x, collision_border_size)
			
			right_collision.position = Vector2(size.x, size.y / 2)
			right_collision.shape.size = Vector2(collision_border_size, size.y)
			
			left_collision.position = Vector2(0, size.y / 2)
			left_collision.shape.size = Vector2(collision_border_size, size.y)
		
		top_collision.disabled = not use_border_collisions
		bottom_collision.disabled = not use_border_collisions
		right_collision.disabled = not use_border_collisions
		left_collision.disabled = not use_border_collisions
		

func rotate_box(angle: float, duration: float = default_rotation_transition_duration, ignore_resize_tween: bool = false) -> void:
	if ignore_resize_tween or (not ignore_resize_tween and _can_resize()) and _can_rotate():
		var from_angle: float = rotation
		rotation_requested.emit(from_angle, angle)
		
		rotation_tween = create_tween()
		rotation_tween.tween_property(self, "rotation", angle, duration)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
			
		await rotation_tween.finished
		
		
		rotation_finished.emit(from_angle, angle)
	else:
		if queue_rotation_transitions:
			general_queue.append(RotationTransition.new(angle, duration))


func resize(new_dimensions: Vector2, duration: float = default_resize_transition_duration, ignore_rotation_tween: bool = false):
	if ( ignore_rotation_tween or (not ignore_rotation_tween and _can_rotate()) ) and _can_resize():
		set_physics_process(true)
		
		var from: Vector2 = size
		resize_requested.emit(from, new_dimensions)
		
		resize_tween = create_tween()
		resize_tween.tween_property(self, "size", new_dimensions, duration).from_current()\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
		
		await resize_tween.finished 
		
		pivot_offset = size / 2.0
		
		resize_finished.emit(from, size)
		set_physics_process(false)
		
	else:
		if queue_resize_transitions:
			general_queue.append(ResizeTransition.new(new_dimensions, duration))


func resize_to_original(duration: float = default_resize_transition_duration) -> void:
	resize(initial_rect_size, duration)


func rotate_to_original(duration: float = default_resize_transition_duration) -> void:
	rotate_box(initial_angle, duration)
	
	
func _can_resize() -> bool:
	return resize_tween == null or (resize_tween and not resize_tween.is_running())
	
	
func _can_rotate() -> bool:
	return rotation_tween == null or (rotation_tween and not rotation_tween.is_running())
	
	
func consume_next_queue_transition() -> void:
	if general_queue.size() > 0:
		var transition = general_queue.pop_front()
		
		if transition is ResizeTransition:
			consume_resize_transition(transition)
			
		elif transition is RotationTransition:
			consume_rotation_transition(transition)
			

func consume_resize_transition(resize_transition: ResizeTransition) -> void:
	if delay_between_transitions > 0:
		await get_tree().create_timer(delay_between_transitions).timeout
		
		resize(resize_transition.new_dimension, resize_transition.duration)
	

func consume_rotation_transition(rotation_transition: RotationTransition) -> void:
	if delay_between_transitions > 0:
		await get_tree().create_timer(delay_between_transitions).timeout
	
	rotate_box(rotation_transition.angle, rotation_transition.duration)


func on_resize_finished(_from: Vector2, _to: Vector2):
	consume_next_queue_transition()
	

func on_rotation_finished(_from: float, _to: float):
	consume_next_queue_transition()
