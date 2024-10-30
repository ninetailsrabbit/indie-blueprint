@icon("res://components/drag_drop/2D/draggable_2d.svg")
class_name DraggableSprite2D extends Sprite2D

signal drag_started
signal drag_ended
signal drag_enabled
signal drag_disabled
signal mouse_released
signal picked_up_changed(picked: bool)


@export var reset_position_on_release: bool = true
@export var one_click_drag: bool = false
@export var smooth_factor: float = 20.0
@export var drag_input_action: StringName = InputControls.Drag:
	set(value):
		drag_input_action = value
		
		set_process(InputMap.has_action(drag_input_action))
		
var mouse_region: Button
var current_position: Vector2 = Vector2.ZERO
var m_offset: Vector2 = Vector2.ZERO

var original_global_position: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

var drag_active: bool = false:
	set(value):
		if drag_active != value:
			drag_active = value
			
			if drag_active:
				drag_enabled.emit()
			else:
				drag_disabled.emit()
				
				
var picked_up: bool = false:
	set(value):
		if picked_up != value:
			picked_up = value
			
			picked_up_changed.emit(picked_up)
			
			if picked_up:
				drag_started.emit()
			else:
				drag_ended.emit()
				reset_position()
				
				
func _ready() -> void:
	original_global_position = global_position
	original_position = position
	
	if mouse_region == null:
		mouse_region = Button.new()
		mouse_region.self_modulate.a8 = 0
		add_child(mouse_region)
	
	
	resize_mouse_region()
	mouse_region.button_down.connect(on_mouse_region_pressed)
	mouse_released.connect(on_mouse_released)
	texture_changed.connect(on_texture_changed)
	
	set_process(InputMap.has_action(drag_input_action))
	

func _process(delta: float) -> void:
	if InputMap.has_action(drag_input_action) and Input.is_action_just_released(drag_input_action) and picked_up:
		mouse_released.emit()
		
	elif mouse_region.button_pressed:
		global_position = global_position.lerp(get_global_mouse_position(), smooth_factor * delta) if smooth_factor > 0 else get_global_mouse_position()
		current_position = global_position + m_offset


func reset_position() -> void:
	if is_inside_tree() and reset_position_on_release:
		global_position = original_global_position
		position = original_position


func resize_mouse_region() -> void:
	if mouse_region:
		mouse_region.position = Vector2.ZERO
		mouse_region.anchors_preset = Control.PRESET_FULL_RECT


func on_mouse_region_pressed() -> void:
	picked_up = true
	
	if is_inside_tree():
		m_offset = transform.origin - get_global_mouse_position()


func on_mouse_released() -> void:
	picked_up = false
	
	
func on_texture_changed() -> void:
	if texture:
		resize_mouse_region()
