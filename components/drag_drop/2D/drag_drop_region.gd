@icon("res://components/drag_drop/2D/draggable_2d.svg")
class_name DragDropRegion extends Button


signal dragged
signal released
signal locked
signal unlocked

@export var draggable: Node
@export var reset_position_on_release: bool = true
@export var reset_position_smooth: bool = true
@export var reset_position_smooth_duration: float = 0.25
@export var smooth_lerp_factor: float = 20.0
@export var screen_limit: bool = true
@export_group("Effects")
@export_category("Oscillator")
@export var enable_oscillator: bool = false
@export var spring: float = 200.0
@export var damp: float = 15.0
@export var velocity_multiplier: float = 2.0

@export_category("Punchy hover effect")
@export var enable_punchy_hover: bool = false
@export var punchy_hover_scale: Vector2 = Vector2(1.2, 1.2)
@export var punchy_hover_normal_scale: Vector2 = Vector2.ONE
@export var punchy_hover_duration_enter: float = 0.5
@export var punchy_hover_duration_exit: float = 0.55


var shader_material: ShaderMaterial
var tween_hover: Tween
var tween_rotation: Tween
var tween_position: Tween

var is_locked: bool = false:
	set(value):
		if value != is_locked:
			is_locked = value
			
			if is_locked:
				locked.emit()
			else:
				unlocked.emit()
			
			set_process(is_dragging and not is_locked)
			
var is_dragging: bool = false:
	set(value):
		if value != is_dragging:
			is_dragging = value
			
			if is_dragging:
				dragged.emit()
			else:
				released.emit()
		
			set_process(is_dragging and not is_locked)


var original_z_index: int = 0
var original_position: Vector2 = Vector2.ZERO
var current_position: Vector2 = Vector2.ZERO
var m_offset: Vector2 = Vector2.ZERO

var displacement: float = 0.0 
var oscillator_velocity: float = 0.0
var last_mouse_position: Vector2
var last_position: Vector2
var velocity: Vector2
var current_angle_y_max: float
var current_angle_x_max: float


func _process(delta: float) -> void:
	if not is_locked and is_dragging:
		last_mouse_position = draggable.global_position
		
		draggable.global_position = draggable.global_position.lerp(get_global_mouse_position(), smooth_lerp_factor * delta) if smooth_lerp_factor > 0 else get_global_mouse_position()
		current_position = draggable.global_position + m_offset
		
		if screen_limit:
			
			draggable.global_position = Vector2(
				clampf(draggable.global_position.x, 0 ,get_viewport_rect().size.x), 
				clampf(draggable.global_position.y, 0 ,get_viewport_rect().size.y)
			)
		
		rotate_velocity(delta)
		

func _ready() -> void:
	if draggable == null:
		draggable = get_parent()
		
	assert(is_instance_valid(draggable) and (draggable is Node2D or draggable is Control), "MouseDragRegion: This mouse drag region needs a valid Node2D or Control to works properly")
	
	set_process(false)
	
	name = "DragDropRegion"
	position = Vector2.ZERO
	self_modulate.a8 = 100 ## TODO - CHANGE TO 0 WHEN FINISH DEBUG
	
	original_position = draggable.global_position
	original_z_index = z_index
	
	button_down.connect(on_mouse_drag_region_dragged)
	button_up.connect(on_mouse_drag_region_released)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
	await get_tree().physics_frame
	anchors_preset = Control.PRESET_FULL_RECT
	
	
func lock() -> void:
	is_locked = true
	reset_rotation()


func unlock() -> void:
	is_locked = false


func rotate_velocity(delta: float) -> void:
	if is_locked or not is_dragging or not enable_oscillator: 
		return
		
	# Compute the velocity
	velocity = (draggable.position - last_position) / delta
	last_position = draggable.position
	
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	draggable.rotation = displacement
	
	
func punchy_hover() -> void:
	if not is_locked and not is_dragging and enable_punchy_hover:
		if tween_hover and tween_hover.is_running():
			tween_hover.kill()
		
		tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_hover.tween_property(draggable, "scale", punchy_hover_scale, punchy_hover_duration_enter)


func punchy_hover_reset() -> void:
	if not is_locked and not is_dragging and enable_punchy_hover:
		if tween_hover and tween_hover.is_running():
			tween_hover.kill()
			
		tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_hover.tween_property(draggable, "scale", punchy_hover_normal_scale, punchy_hover_duration_exit)


func reset_position() -> void:
	if reset_position_on_release:
		lock()
		
		if reset_position_smooth:
			if tween_position and tween_position.is_running():
				tween_position.kill()
				
			tween_position = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
			tween_position.tween_property(draggable, "global_position", original_position, reset_position_smooth_duration)
			
			await tween_position.finished
		else:
			global_position = original_position
		
		unlock()


func reset_rotation() -> void:
	if tween_rotation and tween_rotation.is_running():
		tween_rotation.kill()
	
	tween_rotation = create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween_rotation.tween_property(draggable, "rotation", 0.0, reset_position_smooth_duration)
	await tween_rotation.finished
	

#region Signal callbacks
func on_mouse_drag_region_dragged() -> void:
	if not is_locked:
		is_dragging = true
		draggable.z_index = original_z_index + 100
		draggable.z_as_relative = false
		m_offset = draggable.global_position - get_global_mouse_position()


func on_mouse_drag_region_released() -> void:
	if not is_locked:
		is_dragging = false
		draggable.z_index = original_z_index
		draggable.z_as_relative = true
		
		punchy_hover_reset()
		reset_position()
		reset_rotation()


func on_mouse_entered() -> void:
	punchy_hover()


func on_mouse_exited() -> void:
	punchy_hover_reset()

#endregion
