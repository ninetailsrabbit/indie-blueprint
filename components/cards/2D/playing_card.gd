class_name PlayingCard extends Node2D

signal faced_up
signal faced_down
signal holded
signal released
signal hovered
signal mouse_entered
signal mouse_exited
signal focus_entered
signal focus_exited


@export var sprite: Sprite2D
@export var card_area: Area2D
@export var card_detection_area: Area2D
@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var size: Vector2 = Vector2(60, 96)
@export var front_texture: Texture2D
@export var back_texture: Texture2D
## The meta value from the card
@export var value: int = 1
## The value that this card have in the table, can differ from the meta value
@export var table_value: int = 1
@export_group("Drag")
@export var reset_position_on_release: bool = true
@export var smooth_factor: float = 20.0

enum Orientation {
	FaceUp,
	FaceDown
}


var card_orientation: PlayingCard.Orientation = Orientation.FaceDown:
	set(value):
		if card_orientation != value:
			card_orientation = value
			
			if is_face_up():
				faced_up.emit()
			else:
				faced_down.emit()
				
				
var original_z_index: int = 0
var original_position: Vector2 = Vector2.ZERO
var current_position: Vector2 = Vector2.ZERO
var m_offset: Vector2 = Vector2.ZERO
var is_holded: bool = false:
	set(value):
		if value != is_holded:
			is_holded = value
			
			if is_holded:
				holded.emit()
			else:
				released.emit()
				
			set_process(is_holded)
			_enable_areas_based_on_drag()
			
var mouse_region: Button

		
func _enter_tree() -> void:
	name = display_name
	
	## This card can be reparented when enter a deck pile so we need to create this signal check
	if not faced_up.is_connected(on_faced_up):
		faced_up.connect(on_faced_up)
		
	if not faced_down.is_connected(on_faced_down):
		faced_down.connect(on_faced_down)


func _ready() -> void:
	assert(sprite is Sprite2D, "PlayingCard: The playing card %s needs a Sprite2D node to display the card texture" % id)
	
	set_process(false)
	
	sprite.texture = front_texture
	
	if not size.is_zero_approx():
		var texture_size: Vector2 = sprite.texture.get_size()
		sprite.scale = Vector2(size.x / texture_size.x, size.y / texture_size.y)
	
	_prepare_mouse_region_button()
	_prepare_areas()
	_enable_areas_based_on_drag()
	
	original_position = global_position
	original_z_index = z_index


func _process(delta: float) -> void:
	global_position = global_position.lerp(get_global_mouse_position(), smooth_factor * delta) if smooth_factor > 0 else get_global_mouse_position()
	current_position = global_position + m_offset
	

#region Card orientation
func is_face_up() -> bool:
	return card_orientation == Orientation.FaceUp
	
	
func is_face_down() -> bool:
	return card_orientation == Orientation.FaceDown
	
	
func face_up() -> void:
	card_orientation = Orientation.FaceUp 
	
	
func face_down() -> void:
	card_orientation = Orientation.FaceDown 

	
func flip() -> void:
	if is_face_up():
		face_down()
	else:
		face_up()
#endregion
	
	
#region Values
func is_joker() -> bool:
	return value == 0
	
	
func is_ace() -> bool:
	return value == 1
#endregion


#region Overridables
func is_number() -> bool:
	return false


func is_jack() -> bool:
	return false
	
	
func is_queen() -> bool:
	return false
	

func is_knight() -> bool:
	return false
	
	
func is_king() -> bool:
	return false

#endregion


#region Private
func _prepare_mouse_region_button() -> void:
	if mouse_region == null:
		mouse_region = Button.new()
		mouse_region.self_modulate.a8 = 0 ## TODO - CHANGE TO 0 WHEN FINISH DEBUG
	
	if sprite is Sprite2D:
		sprite.add_child(mouse_region)
		
	mouse_region.position = Vector2.ZERO
	mouse_region.anchors_preset = Control.PRESET_FULL_RECT
	mouse_region.pressed.connect(on_mouse_region_pressed)
	mouse_region.button_down.connect(on_mouse_region_holded)
	mouse_region.button_up.connect(on_mouse_region_released)
	mouse_region.mouse_entered.connect(on_mouse_region_mouse_entered)
	mouse_region.mouse_exited.connect(on_mouse_region_mouse_exited)
	mouse_region.focus_entered.connect(on_mouse_region_focus_entered)
	mouse_region.focus_exited.connect(on_mouse_region_focus_exited)
	

func _prepare_areas() -> void:
	card_area.collision_layer = GameGlobals.playing_cards_collision_layer
	card_area.collision_mask = 0
	card_area.monitorable = true
	card_area.monitoring = false
	card_detection_area.priority = 1
	card_area.get_child(0).shape.size = mouse_region.size * sprite.scale
	
	card_detection_area.collision_layer = 0
	card_detection_area.collision_mask = GameGlobals.playing_cards_collision_layer
	card_detection_area.monitorable = false
	card_detection_area.monitoring = true
	card_detection_area.priority = 2
	card_detection_area.get_child(0).shape.size = mouse_region.size * 0.85 * sprite.scale
	
	card_detection_area.area_entered.connect(on_detected_card)
	
	
func _enable_areas_based_on_drag() -> void:
	#card_area.set_deferred("monitorable", not is_holded)
	card_detection_area.set_deferred("monitoring", is_holded)
#endregion

#region Signal callbacks
func on_faced_up() -> void:
	sprite.texture = front_texture
	
	
func on_faced_down() -> void:
	sprite.texture = back_texture
	
	
func on_detected_card(other_area: Area2D) -> void:
	var detected_card = other_area.get_parent()
	
	if detected_card != self:
		print("detected card ", detected_card)

		
	
func on_mouse_region_pressed() -> void:
	pass
		

func on_mouse_region_holded() -> void:
	if not is_holded:
		m_offset = transform.origin - get_global_mouse_position()
		is_holded = true
		z_index = original_z_index + 100
		z_as_relative = false

			
func on_mouse_region_released() -> void:
	reset_position()
	is_holded = false
	z_index = original_z_index
	z_as_relative = true


func reset_position() -> void:
	if reset_position_on_release:
		global_position = original_position


func on_mouse_region_mouse_entered() -> void:
	mouse_entered.emit()
	
	
func on_mouse_region_mouse_exited() -> void:
	mouse_exited.emit()
	

func on_mouse_region_focus_entered() -> void:
	focus_entered.emit()
	
	
func on_mouse_region_focus_exited() -> void:
	focus_exited.emit()
#endregion
