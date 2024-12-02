@icon("res://components/cards/2D/icons/player_hand.svg")
class_name PlayingCardsHand extends Control

signal added_card(card: PlayingCardUI)
signal added_cards(cards: Array[PlayingCardUI])
signal removed_card(card: PlayingCardUI)
signal add_card_request_denied(card: PlayingCardUI)
signal add_cards_request_denied(card: Array[PlayingCardUI])
signal sorted_cards(previous: Array[PlayingCardUI], current: Array[PlayingCardUI])


@export var id: StringName
@export var default_card_orientation: PlayingCard.Orientation = PlayingCard.Orientation.FaceUp
@export var maximum_cards: int = 4:
	set(value):
		maximum_cards = maxi(1, value)
@export var display_layout_mode: Layouts = Layouts.Horizontal:
	set(value):
		if display_layout_mode != value:
			display_layout_mode = value
			
			if is_inside_tree():
				adjust_hand_position()
			
@export_category("Horizontal layout")
@export var horizontal_distance_offset: Vector2 = Vector2(2, 0)
@export var min_horizontal_y_offset: float = 0.0
@export var max_horizontal_y_offset: float = 0.0
@export_range(0, 360.0, 0.01, "degrees") var min_horizontal_rotation: float = 0.0
@export_range(0, 360.0, 0.01, "degrees") var max_horizontal_rotation: float = 0.0
@export_category("Irregular Fan layout")
@export var fan_card_offset_x: float = 20.0
@export_range(0, 360.0, 0.01, "degrees") var fan_rotation_max: float = 10.0
@export_category("Perfect Arc Fan layout")
## The distance of the cards aligned, more the radius, more the arc range
@export var hand_radius: float = 250.0
@export_range(0, 360.0, 0.01, "degrees") var angle_limit: float = 45.0
@export_range(0, 360.0, 0.01, "degrees")var max_card_spread_angle: float = 15.0

enum Layouts {
	Horizontal,
	IrregularFan,
	PerfectArcFan
}

var current_cards: Array[PlayingCardUI] = []


func _ready() -> void:
	fan_rotation_max = deg_to_rad(fan_rotation_max)
	min_horizontal_rotation = deg_to_rad(min_horizontal_rotation)
	max_horizontal_rotation = deg_to_rad(max_horizontal_rotation)


func _enter_tree() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	
	added_card.connect(on_added_card)
	removed_card.connect(on_removed_card)


func adjust_hand_position(except: Array[PlayingCardUI] = []) -> void:
	var target_cards: Array[PlayingCardUI] = current_cards.filter(
		func(card: PlayingCardUI): 
			return not card in except and not card.is_being_dragged()
			)
	
	match display_layout_mode:
		Layouts.Horizontal:
			_horizontal_layout(target_cards)
		Layouts.IrregularFan:
			_irregular_fan_layout(target_cards)
		Layouts.PerfectArcFan:
			_perfect_arc_layout(target_cards)


func add_card(card: PlayingCardUI) -> void:
	if current_cards.size() == maximum_cards or current_cards.has(card):
		add_card_request_denied.emit(card)
	else:
		if not card.is_inside_tree():
			add_child(card)
			card.card.default_orientation = default_card_orientation
			
			if default_card_orientation == PlayingCard.Orientation.FaceUp:
				card.face_up()
			else:
				card.face_down()
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		card.drag_drop_region.dragged.connect(on_card_dragged.bind(card))
		card.drag_drop_region.released.connect(on_card_released.bind(card))
		
		current_cards.append(card)
		added_card.emit(card)
		

func add_cards(cards: Array[PlayingCardUI] = []) -> void:
	if current_cards.size() == maximum_cards:
		add_cards_request_denied.emit(cards)
	else:
		var selected_cards = filter_cards_by_maximum_hand_size(cards)
		
		for card: PlayingCardUI in selected_cards:
			add_card(card)
		
		added_cards.emit(selected_cards)


func remove_card(card: PlayingCardUI):
	if has_card(card):
		if card.drag_drop_region.dragged.is_connected(on_card_dragged.bind(card)):
			card.drag_drop_region.dragged.disconnect(on_card_dragged.bind(card))
			
		if card.drag_drop_region.released.is_connected(on_card_released.bind(card)):
			card.drag_drop_region.released.disconnect(on_card_released.bind(card))
		
		current_cards.erase(card)
		removed_card.emit(card)
		
	
func has_card(card: PlayingCardUI) -> bool:
	return current_cards.has(card)
	

func is_empty() -> bool:
	return current_cards.is_empty()


func sort_cards_by_value_asc() -> void:
	if current_cards.size() > 1:
		var previous_sortered_cards: Array[PlayingCardUI] = current_cards.duplicate()
		
		current_cards.sort_custom(func(a: PlayingCardUI, b: PlayingCardUI): return a.value < b.value)
		sorted_cards.emit(previous_sortered_cards, current_cards)
		
		
func sort_cards_by_value_desc() -> void:
	if current_cards.size() > 1:
		var previous_sortered_cards: Array[PlayingCardUI] = current_cards.duplicate()
		
		current_cards.sort_custom(func(a: PlayingCardUI, b: PlayingCardUI): return a.value > b.value)
		sorted_cards.emit(previous_sortered_cards, current_cards)


func filter_cards_by_maximum_hand_size(cards: Array[PlayingCardUI]) -> Array[PlayingCardUI]:
	return cards.slice(0, maximum_cards - current_cards.size())


func lock_cards() -> void:
	for card: PlayingCardUI in current_cards:
		card.lock()


func unlock_cards() -> void:
	for card: PlayingCardUI in current_cards:
		card.unlock()


#region Layouts
func _horizontal_layout(cards: Array[PlayingCardUI]) -> void:
	var toggle_random_layout: bool = false
	
	for card: PlayingCardUI in cards:
		var index: int = cards.find(card)
		var new_position: Vector2 = index * (card.front_sprite.size + horizontal_distance_offset)
		new_position.y = (-1 if toggle_random_layout else 1) *  randf_range(min_horizontal_y_offset, max_horizontal_y_offset)
		
		card.position = new_position
		card.rotation = (-1 if toggle_random_layout else 1) * randf_range(min_horizontal_rotation, max_horizontal_rotation)
		
		card.drag_drop_region.original_position = card.global_position
		card.drag_drop_region.original_rotation = card.rotation
		
		toggle_random_layout = !toggle_random_layout


func _irregular_fan_layout(cards: Array[PlayingCardUI]) -> void:
	var cards_size: int = cards.size() - 1
		
	for card: PlayingCardUI in cards:
		var index: int = cards.find(card)
		var final_position: Vector2 = -(card.front_sprite.size / 2.0) - Vector2(fan_card_offset_x * (cards_size - index), 0.0)
		final_position.x += (fan_card_offset_x * cards_size) / 2.0
	
		var final_rotation: float = lerp_angle(-fan_rotation_max, fan_rotation_max, float(index) / float(cards_size))
		card.position = final_position
		card.rotation = final_rotation
		card.drag_drop_region.original_position = card.global_position
		card.drag_drop_region.original_rotation = card.rotation
		

func _perfect_arc_layout(cards: Array[PlayingCardUI]):
	var card_spread = min(angle_limit / cards.size(), max_card_spread_angle)
	var current_angle = -(card_spread * (cards.size() - 1)) / 2 - 90
	
	for card in cards:
		_update_card_transform(card, current_angle)
		current_angle += card_spread
	
	#position.y = absf(cards.back().position.y)


func _update_card_transform(card: PlayingCardUI, angle_in_drag: float):
	card.position = Vector2(
		hand_radius * cos(deg_to_rad(angle_in_drag)), 
		hand_radius * sin(deg_to_rad(angle_in_drag))
	)
	
	## This sum keeps the player hand in the same place
	card.position.y += hand_radius
	card.rotation = deg_to_rad(angle_in_drag + 90.0)

	card.drag_drop_region.original_position = card.global_position
	card.drag_drop_region.original_rotation = card.rotation
#endregion

#region Signal callbacks
func on_card_dragged(_card: PlayingCardUI):
	pass
	

func on_card_released(card: PlayingCardUI):
	await GameGlobals.wait(0.1)
	
	## Check if the card released it's still on the hand to readjust the position
	if has_card(card) and card.get_parent() is PlayingCardsHand:
		adjust_hand_position()
		
		
func on_added_card(_card: PlayingCardUI) -> void:
	adjust_hand_position()
	

func on_removed_card(card: PlayingCardUI) -> void:
	adjust_hand_position([card])
#endregion
