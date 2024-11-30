@icon("res://components/cards/2D/icons/playing_card.svg")
class_name PlayingCardSprite extends Node2D

const GroupName: StringName = &"playing-cards"

signal faced_up
signal faced_down


@export var card: PlayingCard
@export_category("Shadow")
@export var shadow_color: Color = Color("080808a8")
@export var shadow_vertical_depth: float = 5.0:
	set(value):
		if shadow_vertical_depth != value:
			shadow_vertical_depth = maxf(0.01, value)
		
		if is_inside_tree() and shadow_sprite:
			shadow_sprite.position.y = front_sprite.position.y + shadow_vertical_depth
		
@export var shadow_horizontal_depth: float = 5.0:
	set(value):
		if shadow_horizontal_depth != value:
			shadow_horizontal_depth = maxf(0.01, value)
			
			if is_inside_tree() and shadow_sprite:
				shadow_sprite.position.y = front_sprite.position.x + shadow_horizontal_depth

@export var max_offset_shadow: float = 1.0
@export_category("2D perspective")
@export var enable_fake_3d: bool = false
@export var perspective_shader: Shader = preload("res://shaders/perspective/2d_perspective.gdshader")
@export_range(0, 360.0, 0.01, "degrees") var angle_x_max: float = 15.0
@export_range(0, 360.0, 0.01, "degrees") var angle_y_max: float = 15.0
@export var reset_fake_3d_duration: float = 0.5

@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var front_sprite: Sprite2D = $FrontSprite
@onready var drag_drop_region: DragDropRegion = $FrontSprite/DragDropRegion
@onready var card_area: Area2D = $CardArea
@onready var card_area_collision: CollisionShape2D = $CardArea/CollisionShape2D
@onready var card_detection_area: Area2D = $CardDetectionArea
@onready var card_detection_area_collision: CollisionShape2D = $CardDetectionArea/CollisionShape2D


var shader_material: ShaderMaterial
var card_orientation: PlayingCard.Orientation = PlayingCard.Orientation.FaceDown:
	set(value):
		if card_orientation != value:
			card_orientation = value
			
			if is_face_up():
				faced_up.emit()
			else:
				faced_down.emit()

var current_angle_x_max: float = PI / 8
var current_angle_y_max: float = PI / 8


func _enter_tree() -> void:
	add_to_group(GroupName)
	

func _ready() -> void:
	current_angle_x_max = deg_to_rad(angle_x_max)
	current_angle_y_max = deg_to_rad(angle_y_max)
	
	if not card.texture_size.is_zero_approx():
		var original_texture_size = card.front_texture.get_size()
		var new_scale = Vector2(card.texture_size.x / original_texture_size.x, card.texture_size.y  / original_texture_size.y)
		
		scale = new_scale
	
	if enable_fake_3d:
		drag_drop_region.gui_input.connect(on_gui_input)
		shader_material = ShaderMaterial.new()
		shader_material.shader = perspective_shader
		front_sprite.material = shader_material
		
	_connect_to_drag_drop_signals()
	_prepare_shadow()
	_prepare_areas()
	
	face_down()


func enable_detection_areas(enable: bool) -> void:
	card_area.set_deferred("monitorable", enable)
	card_detection_area.set_deferred("monitoring", enable)


func lock() -> void:
	enable_detection_areas(false)
	drag_drop_region.lock()


func unlock() -> void:
	enable_detection_areas(true)
	drag_drop_region.unlock()
	reset_fake_3d_perspective()
	
	
func is_being_dragged() -> bool:
	return drag_drop_region.is_dragging
	
	
func is_locked() -> bool:
	return drag_drop_region.is_locked


#region Card Effects
func fake_3d_perspective() -> void:
	if enable_fake_3d and front_sprite.material and not is_being_dragged() and not is_locked():
		var mouse_pos: Vector2 = drag_drop_region.get_local_mouse_position()

		var lerp_val_x: float = remap(mouse_pos.x, 0.0, drag_drop_region.size.x, 0, 1)
		var lerp_val_y: float = remap(mouse_pos.y, 0.0, drag_drop_region.size.y, 0, 1)

		var rot_x: float = rad_to_deg(lerp_angle(-current_angle_x_max, current_angle_x_max, lerp_val_x))
		var rot_y: float = rad_to_deg(lerp_angle(current_angle_y_max, -current_angle_y_max, lerp_val_y))

		front_sprite.material.set_shader_parameter("x_rot", rot_y)
		front_sprite.material.set_shader_parameter("y_rot", rot_x)


func reset_fake_3d_perspective() -> void:
	if enable_fake_3d and front_sprite.material:
		var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(front_sprite, "material:shader_parameter/x_rot", 0.0, reset_fake_3d_duration)
		tween.tween_property(front_sprite, "material:shader_parameter/y_rot", 0.0, reset_fake_3d_duration)
#endregion


#region Card orientation
func flip() -> void:
	if is_face_up():
		face_down()
	else:
		face_up()


func is_face_up() -> bool:
	return card_orientation == PlayingCard.Orientation.FaceUp
	
	
func is_face_down() -> bool:
	return card_orientation == PlayingCard.Orientation.FaceDown
	
	
func face_up() -> void:
	card_orientation = PlayingCard.Orientation.FaceUp 
	front_sprite.texture = card.front_texture
	
	
func face_down() -> void:
	if card.back_texture:
		card_orientation = PlayingCard.Orientation.FaceDown 
		front_sprite.texture = card.back_texture
#endregion


#region Preparation
func _connect_to_drag_drop_signals() -> void:
	drag_drop_region.button_down.connect(on_drag_drop_region_holded)
	drag_drop_region.button_up.connect(on_drag_drop_region_released)
	drag_drop_region.mouse_entered.connect(on_drag_drop_region_mouse_entered)
	drag_drop_region.mouse_exited.connect(on_drag_drop_region_mouse_exited)
	drag_drop_region.focus_entered.connect(on_drag_drop_region_focus_entered)
	drag_drop_region.focus_exited.connect(on_drag_drop_region_focus_exited)
	
	
func _prepare_shadow() -> void:
	if front_sprite.texture:
		shadow_sprite.texture = front_sprite.texture
		shadow_sprite.scale = front_sprite.scale
		shadow_sprite.show_behind_parent = true
		shadow_sprite.self_modulate = shadow_color
		shadow_sprite.position.x = front_sprite.position.x + shadow_horizontal_depth
		shadow_sprite.position.y = front_sprite.position.y + shadow_vertical_depth
		shadow_sprite.hide()
		
		
func _prepare_areas() -> void:
	await get_tree().physics_frame
	
	card_area.collision_layer = GameGlobals.playing_cards_collision_layer
	card_area.collision_mask = 0
	card_area.monitorable = true
	card_area.monitoring = false
	card_area.priority = 1
	card_area_collision.shape.size = drag_drop_region.size * front_sprite.scale
	
	card_detection_area.collision_layer = 0
	card_detection_area.collision_mask = GameGlobals.playing_cards_collision_layer
	card_detection_area.monitorable = false
	card_detection_area.monitoring = true
	card_detection_area.priority = 2
	card_detection_area_collision.shape.size = drag_drop_region.size * 0.85 * front_sprite.scale
	card_detection_area.area_entered.connect(on_detected_card)
#endregion



#region Signal callbacks
func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		fake_3d_perspective()


func on_detected_card(other_area: Area2D) -> void:
	var detected_card = other_area.get_parent()
	
	if detected_card != self:
		pass


func on_drag_drop_region_holded() -> void:
	if not is_locked():
		card_detection_area.set_deferred("monitoring", true)
		
		shadow_sprite.show()
		reset_fake_3d_perspective()
			

func on_drag_drop_region_released() -> void:
	shadow_sprite.hide()


func on_drag_drop_region_mouse_entered() -> void:
	pass


func on_drag_drop_region_mouse_exited() -> void:
	reset_fake_3d_perspective()
	

func on_drag_drop_region_focus_entered() -> void:
	pass
	
	
func on_drag_drop_region_focus_exited() -> void:
	reset_fake_3d_perspective()

#endregion
