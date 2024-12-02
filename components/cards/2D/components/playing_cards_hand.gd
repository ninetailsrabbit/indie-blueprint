@icon("res://components/cards/2D/icons/player_hand.svg")
class_name PlayingCardsHand extends Control

signal added_card(card: PlayingCardUI)
signal added_cards(cards: Array[PlayingCardUI])
signal removed_card(card: PlayingCardUI)
signal add_card_request_denied(card: PlayingCardUI)
signal add_cards_request_denied(card: Array[PlayingCardUI])
signal sorted_cards(previous: Array[PlayingCardUI], current: Array[PlayingCardUI])


@export var id: StringName
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
@export var arc_distance_offset: float = -12.0
@export_range(0, 360.0, 0.01, "degrees") var arc_spread_angle: float = 30.0 
@export var arc_height: float = 5.0


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
		
		await get_tree().process_frame
		
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
		

func _perfect_arc_layout(cards: Array[PlayingCardUI]) -> void:
	var cards_size: int = cards.size()
	var waveform: Array[float] = _generate_waveform(cards_size)
	
	for card: PlayingCardUI in cards:
		var index: int = cards.find(card)
		
		card.position.x = index * (card.front_sprite.size.x + arc_distance_offset)
		card.position.y = 0
		
		var angle_offset: float = 0.0
		
		if cards_size > 1:
			angle_offset = arc_spread_angle * (index - (cards_size / 2.0)) / (cards_size - 1)
		
		var y_offset: float = arc_height * waveform[index]
		
		card.position.y -= y_offset
		card.rotation = deg_to_rad(angle_offset)
		
		card.drag_drop_region.original_position = card.global_position
		card.drag_drop_region.original_rotation = card.rotation
		
		
func _generate_waveform(range_length: int) -> Array[float]:
	var output: Array[float] = []
	var half_range: float = range_length / 2.0
	var peak_value: float = floorf(half_range)
	
	# Iterate through the range and calculate output based on position
	for i: int in range(range_length):
		# Calculate how far the index is from the middle of the range
		var distance_from_middle: float = absf(i - half_range + 0.5)
		# Determine the output value (inverse of distance from middle)
		var value: float = peak_value - distance_from_middle
		
		output.append(maxf(0, floorf(value) * 1.5))

	return output
#endregion

#region Signal callbacks
func on_card_dragged(card: PlayingCardUI):
	if has_card(card):
		adjust_hand_position()
	

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
