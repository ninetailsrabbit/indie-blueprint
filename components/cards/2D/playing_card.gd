@icon("res://components/cards/2D/icons/playing_card.svg")
class_name PlayingCard extends Control

const GroupName: StringName = &"playing-cards"

const SpanishSuits: Array[Suits] = [
	Suits.Cup,
	Suits.Gold,
	Suits.Club,
	Suits.Sword,
]

const FrenchSuits: Array[Suits] = [
	Suits.Heart,
	Suits.Diamond,
	Suits.Club,
	Suits.Spade
]

signal faced_up
signal faced_down
signal holded
signal released
signal hovered
signal locked
signal unlocked

@export var front_sprite: TextureRect
@export var back_sprite: TextureRect
@export var shadow_sprite: TextureRect
@export var card_area: Area2D
@export var card_detection_area: Area2D
@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var texture_size: Vector2 = Vector2.ZERO
@export var front_texture: Texture2D
@export var back_texture: Texture2D
@export var suit: Suits

## The meta value from the card
@export var value: float = 1.0
## The value that this card have in the table, can differ from the meta value
@export var table_value: float = 1.0
@export var bypass_deck_pile_conditions: bool = false
@export_category("Shadow")
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

@export var max_offset_shadow: float = 50.0



@onready var mouse_drag_region: DragDropRegion = %MouseDragRegion


enum Suits {
	Cup,
	Gold,
	Sword,
	Club,
	Heart,
	Diamond,
	Spade,
	Joker,
	Back
}


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
				
				
var is_holded: bool = false:
	set(value):
		if value != is_holded:
			is_holded = value
			
			if is_holded:
				holded.emit()
			else:
				released.emit()
				
			set_process(is_holded and not is_locked)
			_enable_areas_based_on_drag()
			
var is_locked: bool = false:
	set(value):
		if value != is_locked:
			is_locked = value
			
			set_process(is_holded and not is_locked)
			
			if is_locked:
				mouse_drag_region.lock()
				locked.emit()
			else:
				mouse_drag_region.unlock()
				unlocked.emit()



func _enter_tree() -> void:
	add_to_group(GroupName)
	
	if not display_name.is_empty():
		name = display_name
	
	## This card can be reparented when enter a deck pile so we need to create this signal check
	if not faced_up.is_connected(on_faced_up):
		faced_up.connect(on_faced_up)
		
	if not faced_down.is_connected(on_faced_down):
		faced_down.connect(on_faced_down)


func _ready() -> void:
	assert(front_sprite is TextureRect, "PlayingCard: The playing card %s needs a TextureRect node to display the card texture" % id)
	
	set_process(false)

	_prepare_sprite()
	_prepare_mouse_drag_region_button()
	_prepare_areas()
	_enable_areas_based_on_drag()
	

func _process(delta: float) -> void:
	if not is_locked:
		handle_shadow(delta)
		
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
	
	
func lock() -> void:
	is_locked = true


func unlock() -> void:
	is_locked = false
	
	
func disable_detection_areas() -> void:
	card_area.set_deferred("monitorable", false)
	card_detection_area.set_deferred("monitoring", false)


func hold_card() -> void:
	if not is_holded and not is_locked:
		shadow_sprite.show()
		is_holded = true


func release_card_from_drag() -> void:
	if not is_locked:
		shadow_sprite.hide()
		is_holded = false
		
	
func handle_shadow(_delta: float) -> void:
	# Y position is never changed.
	# Only x changes depending on how far we are from the center of the screen
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	
	shadow_sprite.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance / (center.x)))

#endregion
	
	
#region Values
func is_spanish() -> bool:
	return suit in SpanishSuits
	

func is_french() -> bool:
	return suit in FrenchSuits


func is_joker() -> bool:
	return value == 0
	
	
func is_ace() -> bool:
	return value == 1
#endregion


#region Overridables
func is_number() -> bool:
	return value > 1 and value < 11 if is_french() else value > 1 and value < 8


func is_jack() -> bool:
	return value == 11 if is_french() else value == 10
	
	
func is_queen() -> bool:
	return value == 12 if is_french() else value == 11


func is_knight() -> bool:
	return value == 12 if is_french() else value == 11
	
	
func is_king() -> bool:
	return value == 13 if is_french() else value == 12
#endregion


#region Private
func _prepare_sprite() -> void:
	front_sprite.texture = front_texture
	
	var current_texture_size: Vector2 = front_sprite.texture.get_size()
	
	if not texture_size.is_zero_approx():
		current_texture_size = texture_size
		
		front_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		shadow_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		back_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		front_sprite.custom_minimum_size = current_texture_size
		shadow_sprite.custom_minimum_size = current_texture_size
		back_sprite.custom_minimum_size = current_texture_size
		front_sprite.size = current_texture_size
		shadow_sprite.size = current_texture_size
		back_sprite.size = current_texture_size
		
	front_sprite.position = -current_texture_size / 2.0
	
	back_sprite.scale = front_sprite.scale
	back_sprite.position = front_sprite.position
	back_sprite.hide()
	
	shadow_sprite.position = front_sprite.position
	shadow_sprite.texture = front_sprite.texture
	shadow_sprite.scale = front_sprite.scale
	shadow_sprite.show_behind_parent = true
	shadow_sprite.self_modulate = Color("1616166f")
	shadow_sprite.position.x = front_sprite.position.x + shadow_horizontal_depth
	shadow_sprite.position.y = front_sprite.position.y + shadow_vertical_depth
	shadow_sprite.hide()
	
	pivot_offset = -current_texture_size / 2.0


func _prepare_mouse_drag_region_button() -> void:
	mouse_drag_region.pressed.connect(on_mouse_drag_region_pressed)
	mouse_drag_region.button_down.connect(on_mouse_drag_region_holded)
	mouse_drag_region.button_up.connect(on_mouse_drag_region_released)
	mouse_drag_region.mouse_entered.connect(on_mouse_drag_region_mouse_entered)
	mouse_drag_region.mouse_exited.connect(on_mouse_drag_region_mouse_exited)
	mouse_drag_region.focus_entered.connect(on_mouse_drag_region_focus_entered)
	mouse_drag_region.focus_exited.connect(on_mouse_drag_region_focus_exited)
	

func _prepare_areas() -> void:
	#card_area.position = mouse_drag_region.size / 2.0
	card_area.collision_layer = GameGlobals.playing_cards_collision_layer
	card_area.collision_mask = 0
	card_area.monitorable = true
	card_area.monitoring = false
	card_detection_area.priority = 1
	card_area.get_child(0).shape.size = mouse_drag_region.size * front_sprite.scale
	
	#card_detection_area.position = mouse_drag_region.size / 2.0
	card_detection_area.collision_layer = 0
	card_detection_area.collision_mask = GameGlobals.playing_cards_collision_layer
	card_detection_area.monitorable = false
	card_detection_area.monitoring = true
	card_detection_area.priority = 2
	card_detection_area.get_child(0).shape.size = mouse_drag_region.size * 0.85 * front_sprite.scale
	
	card_detection_area.area_entered.connect(on_detected_card)
	
	
func _enable_areas_based_on_drag() -> void:
	card_detection_area.set_deferred("monitoring", is_holded and not is_locked)
#endregion

#region Signal callbacks
func on_faced_up() -> void:
	front_sprite.show()
	back_sprite.hide()
	
	
func on_faced_down() -> void:
	front_sprite.hide()
	back_sprite.show()
	
	
func on_detected_card(other_area: Area2D) -> void:
	var detected_card = other_area.get_parent()
	
	if detected_card != self:
		pass


func on_mouse_drag_region_pressed() -> void:
	pass


func on_mouse_drag_region_holded() -> void:
	hold_card()
			

func on_mouse_drag_region_released() -> void:
	release_card_from_drag()


func on_mouse_drag_region_mouse_entered() -> void:
	mouse_entered.emit()
	hovered.emit()
	
func on_mouse_drag_region_mouse_exited() -> void:
	mouse_exited.emit()
	

func on_mouse_drag_region_focus_entered() -> void:
	focus_entered.emit()
	
	
func on_mouse_drag_region_focus_exited() -> void:
	focus_exited.emit()
#endregion
